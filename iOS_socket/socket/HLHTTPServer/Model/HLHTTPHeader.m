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

- (BOOL)hasRangeHead;
{
    return [self.headDic[@"Range"] hasPrefix:@"bytes="];
}
@end

@implementation HLHTTPHeaderResponse

- (instancetype)init
{
    if (self = [super init]) {
        self.headDic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (NSData *)dataOfHeader{
    NSMutableString *headStr = @"".mutableCopy;
    [headStr appendFormat:@"%@/%@ %zd %@\r\n",self.protocol,self.version, self.stateCode, self.stateDesc];
    [self.headDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [headStr appendFormat:@"%@:%@\r\n",key,obj];
    }];
    [headStr appendString:@"\r\n"];
    return [headStr dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) setContentLength:(u_int64_t)contentLength
{
    _contentLength = contentLength;
    [self.headDic setObject:@(contentLength) forKey:@"Content-Length"];
//    [self.headDic setValue:@(contentLength) forKey:@"Content-Length"];
}

//或者使用CFNetwork
//- (void)setHeaderField:(NSString *)headerField value:(NSString *)headerFieldValue
//{
//    CFHTTPMessageSetHeaderFieldValue(self.message,
//                                     (__bridge CFStringRef)headerField,
//                                     (__bridge CFStringRef)headerFieldValue);
//}
//
//- (NSData *)messageData
//{
//    return (__bridge_transfer NSData *)CFHTTPMessageCopySerializedMessage(self.message);
//}
//
//
//- (void)setBody:(NSData *)body
//{
//    CFHTTPMessageSetBody(self.message, (__bridge CFDataRef)body);
//}
@end
