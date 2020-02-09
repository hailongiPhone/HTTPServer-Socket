//
//  HLHTTPConnect.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSocketConnect.h"
#import "HLHTTPResponse.h"
#import "HLHTTPRequest.h"

/**
 *  HLHTTPConnect 处理客户端的连接
 *      线程--默认运行在Socket连接的线程，可以单独指定
 *
 */

NS_ASSUME_NONNULL_BEGIN

@protocol HLHTTPConnectDelegate <NSObject>

-(HLHTTPResponse*) responseForRequest:(HLHTTPRequest*)request;

@end

@interface HLHTTPConnect : NSObject
@property (nonatomic,weak) id<HLHTTPConnectDelegate> delegate;

- (instancetype)initWith:(HLSocketConnect *)socketConnect;

- (void)connect;
- (void)disconnect;
- (void)readPackageData:(NSData*)data packageTag:(NSInteger)tag;
- (void)writeDonePackageTag:(NSInteger)tag;
@end

NS_ASSUME_NONNULL_END
