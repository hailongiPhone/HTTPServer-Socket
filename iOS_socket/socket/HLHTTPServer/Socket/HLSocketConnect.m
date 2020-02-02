//
//  HLSocketConnect.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLSocketConnect.h"
#import <sys/socket.h>
#import <sys/un.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <unistd.h>

#import "HLPackageRead.h"
#import "HLSocketWriter.h"


typedef NS_ENUM(NSUInteger, SocketConnectState) {
    SocketConnectStateWaitReadData          = 1,
    SocketConnectStateReading               ,
    SocketConnectStateReadingSuspend       ,
    
    SocketConnectStateWaitWriteData         ,
    SocketConnectStateWriting               ,
    SocketConnectStateWritingSuspend        ,
    
    SocketConnectStateDisconnecting         ,
    SocketConnectStateEOF                   ,
};

@interface HLSocketConnect ()
@property (nonatomic,strong) dispatch_queue_t queue;
@property (nonatomic,strong) dispatch_source_t readSoure;
@property (nonatomic,strong) dispatch_source_t writeSoure;

@property(nonatomic,strong) HLSocketReader * reader;
@property(nonatomic,strong) HLSocketWriter * writer;
@property(nonatomic,assign) SocketConnectState readState;
@property(nonatomic,assign) SocketConnectState writeState;

@property (nonatomic,strong) dispatch_queue_t delegateQueue;
@end

@implementation HLSocketConnect
- (instancetype) initWithSocketFD:(int)fd;
{
    if (self=[super init]) {
        [self setupWith:fd];
    }
    return self;
}

- (void)setupWith:(int)connectionFD;
{
    self.socketFD = connectionFD;
    __weak typeof(self) weakSelf = self;
    int nosigpipe = 1;
    setsockopt(connectionFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    
    // Enable non-blocking IO on the socket
    int result = fcntl(connectionFD, F_SETFL, O_NONBLOCK);
    if (result == -1)
    {
        return;
    }
    
    NSString * name = [NSString stringWithFormat:@"SubReactor %d",connectionFD];
    dispatch_queue_t queue = dispatch_queue_create([name UTF8String], NULL);
    self.queue = queue;
    
    
    
    dispatch_source_t readsource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                     connectionFD, 0, queue);
    
    
    dispatch_source_set_event_handler(readsource, ^{
       // Get some data from the source variable, which is captured
       // from the parent context.
       size_t estimated = dispatch_source_get_data(readsource);
        NSLog(@"dispatch_source_set_event_handler--readsource %ld",estimated);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (estimated > 0)
            [strongSelf doReadData:connectionFD length:estimated];
        else
            [strongSelf doReadEOF:connectionFD];
    });
//    dispatch_resume(readsource);
    self.readSoure = readsource;
    
    dispatch_source_t writesource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE,
                                     connectionFD, 0, queue);
    dispatch_source_set_event_handler(writesource, ^{
        NSLog(@"dispatch_source_set_event_handler--writesource = %ld",dispatch_source_get_data(writesource));
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf doWrite];
    });
//    dispatch_resume(writesource);
    self.writeSoure = writesource;
    
    dispatch_source_set_cancel_handler(readsource, ^{
        [weakSelf dispose];
    });
    
    dispatch_source_set_cancel_handler(writesource, ^{
        [weakSelf dispose];
    });
    
    [self resetState];
    
}

//具体从sockets中读取数据
//数据处理--分数据报读取
//关闭回调 -- 完成关闭回调
//进度更新回调，省略大多数报文都是按照特殊字符结尾，不知道报文具体长度，只知道当前读取长度
- (void)doReadData:(int)connectionFD length:(NSInteger)length;
{
    if (length < 1) {
        return;
    }
    

    ssize_t total = 0;
    int time = 0;
    while (total<length) {
        
        HLSocketReader * reader = [self lazySocketReader];
        uint8_t * buffer = NULL;
        NSUInteger wanttoreadlength = [reader readLengthForEstimatedBytesAvailable:length
                                                                 readBufferPointer:&buffer];
        
        //尝试一次性读
        ssize_t result = 0;
        result = read(connectionFD, buffer, wanttoreadlength);
        
        [reader didRead:result];
        if (result < 0)
        {
            NSLog(@"出错");
        }
        else if (result == 0)
        {
            NSLog(@"socket没有数据了，断开连接？");
        }else{
            NSLog(@"正常读取 %ld",result);
            total += result;
            time++;
        }
        
        [self tryPackageReadDoneCallback];
    }
    
    
}

- (void) tryPackageReadDoneCallback;
{
    HLSocketReader * reader = [self lazySocketReader];
    HLPackageRead * readerDone;
    while ((readerDone = [reader extractDoneRead])) {
        if (self.delegate) {
            [self.delegate connect:self
                   readPackageData:[readerDone bufferData]
                        packageTag:[readerDone tag]];
        }
    }
}

- (HLSocketReader * )lazySocketReader;
{
    if (!self.reader) {
        self.reader = [HLSocketReader new];
    }
    
    return self.reader;
}

- (HLSocketWriter * )lazySockerWrier;
{
    if (!self.writer) {
        self.writer = [HLSocketWriter new];
    }
    
    return self.writer;
}

- (void)doReadEOF:(int)connectionFD;
{
    self.readState = SocketConnectStateEOF;
    [self dispose];
}

- (void)doWrite;
{
    HLSocketWriter * writer = [self lazySockerWrier];
    
    uint8_t * buffer = NULL;
    NSUInteger wanttowritelength = [writer writeLenthWriteBufferPointer:&buffer];
    
    if (wanttowritelength < 1) {
        [self suspendWriteSource];
        return;
    }
    
    //尝试写
    ssize_t result = 0;
    result = write(self.socketFD, buffer, wanttowritelength);
    
    if (result < 0){
        NSLog(@"出错");
    }else{
        [writer didWrite:result];
    }

    HLPackageWriter* package = [writer extractDoneWrite];
    
    if (self.delegate) {
        [self.delegate connect:self
               writePackageData:[package bufferData]
                    packageTag:[package tag]];
    }
}

- (void)dispose;
{
    close(self.socketFD);
    self.queue = nil;
    self.readSoure = nil;
    self.writeSoure = nil;
}

#pragma mark - Interface
- (void) readPackage:(HLPackageRead *)package;
{
    [self asyncRunOnQueue:^{
        HLSocketReader * reader = [self lazySocketReader];
        [reader addPackageReader:package];
    }];
}

- (void) writePackage:(HLPackageWriter *)package;
{
    [self asyncRunOnQueue:^{
        HLSocketWriter * writer = [self lazySockerWrier];
        [writer addPackageWriter:package];
        
        if (self.writeState == SocketConnectStateWritingSuspend) {
            [self resumeWriteSource];
        }
    }];
}
//启动监听事件
- (void)start;
{
    dispatch_resume(self.readSoure);
    self.readState = SocketConnectStateWaitReadData;
    
    [self resumeWriteSource];
}
- (void)stop;
{
    dispatch_suspend(self.readSoure);
    self.readState = SocketConnectStateWaitReadData;
    
    
    [self suspendWriteSource];
}

- (void)resumeWriteSource;
{
    dispatch_resume(self.writeSoure);
    self.writeState = SocketConnectStateWaitWriteData;
}

- (void)suspendWriteSource;
{
    dispatch_suspend(self.writeSoure);
    self.writeState = SocketConnectStateWritingSuspend;
}

- (void)disconnect;
{
    [self stop];
    [self dispose];
    
    if (self.delegate) {
        [self.delegate connectClosed:self];
    }
}

#pragma mark - update State
- (void)resetState;
{
    self.readState = 0;
    self.writeState = 0;
}

#pragma mark -
static int kQueueKey;
- (void)markQueue:(dispatch_queue_t)queue;
{
    void *nonNullUnusedPointer = (__bridge void *)self;
    dispatch_queue_set_specific(queue,&kQueueKey,nonNullUnusedPointer,NULL);
}

- (void) syncRunOnQueue:(void(^)(void))block;
{
    if(dispatch_get_specific(&kQueueKey)){
        block();
    }else{
        dispatch_sync(self.queue, ^{
            block();
        });
    }
}

- (void) asyncRunOnQueue:(void(^)(void))block;
{
    if(dispatch_get_specific(&kQueueKey)){
        block();
    }else{
        dispatch_async(self.queue, ^{
            block();
        });
    }
}


-(void)setDelegate:(id<HLSocketConnectDelegate> _Nullable)delegate
callbackQueue:(dispatch_queue_t)callbackQueue;
{
    self.delegate = delegate;
    self.delegateQueue = callbackQueue;
}

- (id)copyWithZone:(NSZone *)zone{
    
    return self;
}
@end
