//
//  HLHTTPResponseHandler.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPResponseHandler.h"
#import "HLHTTPResponse.h"
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

- (HLPackageWriter *)writerPackageForHeaderInfo;
{
    self.response = [HLHTTPResponseResource responseHandlerWithRequestHeader:self.requestHeader];
    
    return [self.response writerPackageForHeaderInfo];
}
- (HLPackageWriter *)writerPackageBody;
{
    return [self.response writerPackageBody];
}

#pragma mark - Header

@end
