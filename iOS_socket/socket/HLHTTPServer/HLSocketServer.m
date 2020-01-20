//
//  HLSocketServer.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLSocketServer.h"

#import <sys/socket.h>
#import <sys/un.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <unistd.h>

@interface HLSocketServer (){
//    dispatch_queue_t mainReactorQueue;
}
//线程管理
@property (nonatomic,assign) int mainSocket;
@property (nonatomic,strong) dispatch_queue_t mainReactorQueue;
@property (nonatomic,strong) dispatch_source_t mainReactorSocketSource;

@end

@implementation HLSocketServer


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
    int listenfd, connfd;
   socklen_t clilen;
   struct sockaddr_in cliaddr, servaddr;
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
   listen(listenfd, 1024);
    
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
    struct sockaddr_in cliaddr;
    socklen_t clilen;
    clilen = sizeof(cliaddr);
    int connfd = accept(self.mainSocket, (struct sockaddr *) &cliaddr, &clilen);
    
    [self setupSubReactor:connfd];
    
    return YES;
}
//SubReactor 要通过 dispatch source 监听读写事件
//SubReactor 也要使用Thread pool
- (void) setupSubReactor:(int)connectionFD;
{
    int nosigpipe = 1;
    setsockopt(connectionFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    
    NSString * name = [NSString stringWithFormat:@"SubReactor %d",connectionFD];
    dispatch_queue_t queue = dispatch_queue_create([name UTF8String], NULL);
    
    
    
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                     myDescriptor, 0, queue);
    dispatch_source_set_event_handler(source, ^{
       // Get some data from the source variable, which is captured
       // from the parent context.
       size_t estimated = dispatch_source_get_data(source);
     
       // Continue reading the descriptor...
    });
    dispatch_resume(source);
}
@end
