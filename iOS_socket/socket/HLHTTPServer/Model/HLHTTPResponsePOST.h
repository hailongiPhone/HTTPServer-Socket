//
//  HLHTTPResponsePOST.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPHeader.h"
#import "HLHTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN
@interface HLHTTPResponsePOST : HLHTTPResponse
+ (HLHTTPResponse *)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
@end

NS_ASSUME_NONNULL_END
