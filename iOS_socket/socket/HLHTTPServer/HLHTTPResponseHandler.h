//
//  HLHTTPResponseHandler.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HLHTTPHeader.h"
#import "HLPackageWriter.h"
#import "HLHTTPResponse.h"



NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPResponseHandler : NSObject
@property(nonatomic,strong) HLHTTPHeaderRequest * requestHeader;

+(instancetype)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
+(instancetype)responseHandlerWithResponse:(HLHTTPResponse *)response;

- (HLPackageWriter *)writerPackageForHeaderInfo;
- (HLPackageWriter *)writerPackageBody;

- (HLPackageWriter *)writerPackage;
@end

NS_ASSUME_NONNULL_END
