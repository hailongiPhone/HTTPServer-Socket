//
//  HLHTTPHeader.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPHeader.h"

@implementation HLHTTPHeader

@end

@implementation HLHTTPHeaderRequest
- (BOOL)hasBody;
{
    return self.contentLength >0;
}

- (NSString *)fileName;
{
    NSString * fromPath = [self.path lastPathComponent];
    fromPath = [fromPath stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([fromPath length] < 1) {
        fromPath = @"1";
    }
    return fromPath;
}
@end

@implementation HLHTTPHeaderResponse

@end
