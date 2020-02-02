//
//  HLHTTPResponseResource.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPResponseResource : HLHTTPResponse
+(instancetype)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
@end

NS_ASSUME_NONNULL_END
