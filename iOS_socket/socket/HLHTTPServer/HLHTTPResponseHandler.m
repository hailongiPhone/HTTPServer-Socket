//
//  HLHTTPResponseHandler.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPResponseHandler.h"

#import "HLHTTPResponseResource.h"

@interface HLHTTPResponseHandler ()
@property(nonatomic,strong) HLHTTPResponse * response;
@end

@implementation HLHTTPResponseHandler
+(instancetype)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
{
    HLHTTPResponseHandler * tmp = [HLHTTPResponseHandler new];
    tmp.requestHeader = requestHeader;
    return tmp;
}

+(instancetype)responseHandlerWithResponse:(HLHTTPResponse *)response;
{
    HLHTTPResponseHandler * tmp = [HLHTTPResponseHandler new];
    tmp.response = response;
    return tmp;
}

- (HLPackageWriter *)writerPackageForHeaderInfo;
{
    if (!self.response) {
        self.response = [HLHTTPResponse responseHandlerWithRequestHeader:self.requestHeader];
    }
    
    return [self.response writerPackageForHeaderInfo];
    return nil;
}
- (HLPackageWriter *)writerPackageBody;
{
    return [self.response writerPackageBody];
    return nil;
}

- (HLPackageWriter *)writerPackage;
{
    self.response = [HLHTTPResponse responseHandlerWithRequestHeader:self.requestHeader];
    return [self.response writerPackage];
}
#pragma mark - Header

@end
