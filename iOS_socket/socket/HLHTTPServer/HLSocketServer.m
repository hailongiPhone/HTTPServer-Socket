//
//  HLSocketServer.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLSocketServer.h"
#import "HLSocketConnect.h"

#import <sys/socket.h>
#import <sys/un.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <unistd.h>

#define ListenCount 1024

@interface HLSocketServer () <HLSocketConnectDelegate>{
//    dispatch_queue_t mainReactorQueue;
}
//线程管理
@property (nonatomic,assign) int mainSocket;
@property (nonatomic,strong) dispatch_queue_t mainReactorQueue;     //非UI主线程，串行队列
@property (nonatomic,strong) dispatch_source_t mainReactorSocketSource;

@property (nonatomic,strong) NSMutableArray * subReactor;

@property (nonatomic,weak) id<HLSocketServerDelegate> delegate;
@property (nonatomic,strong) dispatch_queue_t delegateQueue;
@end

@implementation HLSocketServer

- (instancetype) init
{
    if (self = [super init]) {
//        [self setupMainReactor:12345];
    }
    
    return self;
}

-(void)setDelegate:(id<HLSocketServerDelegate> _Nullable)delegate
     callbackQueue:(dispatch_queue_t)callbackQueue;
{
    self.delegate = delegate;
    self.delegateQueue = callbackQueue;
}

#pragma mark - Socket
-(void)setupMainReactor:(NSInteger) port;
{
    self.mainReactorQueue = dispatch_queue_create("MainReactor", NULL);
    
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(self.mainReactorQueue, ^{
//        [weakSelf setupSocketLocalHost:port];
//    });
    [self setupSocketLocalHost:port];
}

- (void) setupSocketLocalHost:(NSInteger) port;
{
    int listenfd;
   struct sockaddr_in servaddr;
   listenfd = socket(AF_INET, SOCK_STREAM, 0);
   bzero(&servaddr, sizeof(servaddr));
   servaddr.sin_family = AF_INET;
   servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
   servaddr.sin_port = htons(port);
   
   //端口重用问题
   int on = 1;
   setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
   
   /* bind到本地地址，端口为12345 */
   bind(listenfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
    self.mainSocket = listenfd;
   /* listen的backlog为1024 */
   listen(listenfd, ListenCount);
    
//   /* 循环处理用户请求 */
//   for (;;) {
//       clilen = sizeof(cliaddr);
//       connfd = accept(listenfd, (struct sockaddr *) &cliaddr, &clilen);
//       [self setupSubReactor:connfd];/* 读取数据 */
//       close(connfd);/* 关闭连接套接字，注意不是监听套接字*/
//   }
    
    //使用dispatch source 来监听连接事件 替代死循环
    self.mainReactorSocketSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, listenfd, 0, self.mainReactorQueue);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_source_set_event_handler(self.mainReactorSocketSource, ^{ @autoreleasepool {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;
    
        unsigned long i = 0;
        unsigned long numPendingConnections = dispatch_source_get_data(strongSelf.mainReactorSocketSource);
        
        while ([strongSelf doAccept] && (++i < numPendingConnections));
        
    }});
    
    
    dispatch_source_set_cancel_handler(self.mainReactorSocketSource, ^{
        
        close(weakSelf.mainSocket);
    
    });

    dispatch_resume(self.mainReactorSocketSource);
}


- (BOOL) doAccept;
{
    NSLog(@"doAccept");
    struct sockaddr_in cliaddr;
    socklen_t clilen;
    clilen = sizeof(cliaddr);
    int connfd = accept(self.mainSocket, (struct sockaddr *) &cliaddr, &clilen);
    
    NSLog(@"id = %s",inet_ntoa(cliaddr.sin_addr));
    [self setupSubReactor:connfd];
    
    return YES;
}
//SubReactor 要通过 dispatch source 监听读写事件
//SubReactor 也要使用Thread pool
- (void) setupSubReactor:(int)connectionFD;
{
    if (!self.subReactor) {
        self.subReactor = [[NSMutableArray alloc] initWithCapacity:ListenCount];
    }
    
    HLSocketConnect * aconnect = [[HLSocketConnect alloc] initWithSocketFD:connectionFD];
    aconnect.delegate = self;
    if (self.delegate) {
        [self runBlockOnDelegateQueue:^{
             [self.delegate connect:aconnect];
        }];
    }
    [self.subReactor addObject:aconnect];
    [aconnect start];
}

#pragma mark - Connect Delegate
- (void) connect:(HLSocketConnect *)connect readPackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    if (self.delegate) {
        [self runBlockOnDelegateQueue:^{
            [self.delegate connect:connect readPackageData:data packageTag:tag];
        }];
    }
}

- (void) connect:(HLSocketConnect *)connect writePackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    if (self.delegate) {
           [self runBlockOnDelegateQueue:^{
               [self.delegate connect:connect writePackageData:data packageTag:tag];
           }];
       }
}

- (void) connectClosed:(HLSocketConnect *)connect;
{
    dispatch_async(self.mainReactorQueue, ^{
        [self.subReactor removeObject:connect];
    });
    
    if (self.delegate) {
        [self runBlockOnDelegateQueue:^{
            [self.delegate connectClosed:connect];
        }];
    }
}

#pragma mark - Helper

- (void)runBlockOnDelegateQueue:(void (^)(void))block;
{
    dispatch_sync(self.delegateQueue, ^{
        block();
    });
    
    
}
@end
