//
//  HLSocketServer.h
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  建立iOS本地HttpServer服务器
 *  HLSocketServer 如何高性能（socket IO复用 事件分发 多线程）
 *  多线程 主reactor 负责监听连接，sub-reactor 负责读写事件，worker thread 负责
 *
 *  读写数据-封装buffer
 *  服务器通过HLSocketConnect来处理连接，每个连接都有自己的线程dispatch queue
 */


@class HLSocketConnect;

@protocol HLSocketServerDelegate <NSObject>

- (void) connect:(HLSocketConnect *)connect readPackageData:(NSData*)data packageTag:(NSInteger)tag;
- (void) connect:(HLSocketConnect *)connect writePackageData:(NSData*)data packageTag:(NSInteger)tag;

- (void) connect:(HLSocketConnect *)connect;
- (void) connectClosed:(HLSocketConnect *)connect;

@end

@interface HLSocketServer : NSObject

-(void)setupMainReactor:(NSInteger) port;
-(void)setDelegate:(id<HLSocketServerDelegate> _Nullable)delegate
     callbackQueue:(dispatch_queue_t)callbackQueue;
@end

NS_ASSUME_NONNULL_END
