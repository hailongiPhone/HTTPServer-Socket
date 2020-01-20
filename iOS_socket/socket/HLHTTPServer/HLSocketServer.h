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
 */

@interface HLSocketServer : NSObject

@end

NS_ASSUME_NONNULL_END
