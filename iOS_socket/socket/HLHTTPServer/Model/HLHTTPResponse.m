//
//  HLHTTPResponse.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPResponse.h"
#import "HLHTTPResponsePOST.h"
#import "HLHTTPResponseResource.h"

@implementation HLHTTPResponse
- (HLPackageWriter *)writerPackageForHeaderInfo;
{
    return nil;
}
- (HLPackageWriter *)writerPackageBody;
{
    return nil;
}

- (HLPackageWriter *)writerPackage;
{
    return nil;
}

+ (HLHTTPResponse *)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
{
    if ([requestHeader.method isEqualToString:@"GET"]) {
        return [HLHTTPResponseResource responseHandlerWithRequestHeader:requestHeader];
    }
    
    if ([requestHeader.method isEqualToString:@"POST"]) {
        return [HLHTTPResponseResource responseHandlerWithRequestHeader:requestHeader];
    }
    
    NSLog(@"！！！Not support Method %@",requestHeader.method);
    return nil;
}
@end
