//
//  HLHTTPServer.h
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPRequest.h"
#import "HLHTTPResponse.h"
#import "HLHTTPServerDelegate.h"
#import "HLHTTPServerConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPServer : NSObject

+ (instancetype)serverWithConfig:(void(^)(HLHTTPServerConfig *config)) configBlock;
-(instancetype)initWithConfig:(void(^)(HLHTTPServerConfig *config)) configBlock;

@end

NS_ASSUME_NONNULL_END
