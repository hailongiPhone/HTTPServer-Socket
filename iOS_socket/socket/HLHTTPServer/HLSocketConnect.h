//
//  HLSocketConnect.h
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSocketReader.h"

/**
 *  HLSocketConnect Sockets配对，一条连接一个线程
 *  要保证线程安全才好--读写都是在单独的线程中完成
 */

NS_ASSUME_NONNULL_BEGIN

@class HLSocketConnect;

@protocol HLSocketConnectDelegate <NSObject>

- (void) connect:(HLSocketConnect *)connect readPackageData:(NSData*)data packageTag:(NSInteger)tag;
- (void) connect:(HLSocketConnect *)connect writePackageData:(NSData*)data packageTag:(NSInteger)tag;

- (void) connectClosed:(HLSocketConnect *)connect;

@end

@interface HLSocketConnect : NSObject
@property(nonatomic,assign) int socketFD;



- (instancetype) initWithSocketFD:(int)fd;
@property (nonatomic,weak) id<HLSocketConnectDelegate> delegate;

- (void) readPackage:(HLPackageRead *)package packageTag:(NSInteger)tag;
//启动监听事件
- (void)start;
- (void)stop;

- (void)disconnect;
@end

NS_ASSUME_NONNULL_END
