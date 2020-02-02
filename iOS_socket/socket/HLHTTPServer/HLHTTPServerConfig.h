//
//  HLHTTPServerConfig.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPServerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPServerConfig : NSObject
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, copy) NSString *rootDirectory;
@property(nonatomic, weak) id<HLHTTPRequestDelegate> requestDelegate;
@property(nonatomic, weak) id<HLHTTPResponseDelegate> responseDelegate;
@end

NS_ASSUME_NONNULL_END
