//
//  HLHTTPRequestHandle.m
//  iOS_socket
//
//  Created by hailong on 2020/02/02.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPRequestHandler.h"

@interface HLHTTPRequestHandler ()
@property(nonatomic,strong) HLHTTPRequest * request;
@property(nonatomic,assign) CFHTTPMessageRef message;
@end

@implementation HLHTTPRequestHandler


- (HLPackageRead *)readPackageForHeaderInfo;
{
    return [HLPackageRead packageReadWithTerminator:@"\r\n\r\n" tag:HLRequestPackageTagHeader];
}

- (HLPackageRead *)readPackageBody;
{
    return [HLPackageRead packageReadWithTerminator:@"\r\n\r\n" tag:HLRequestPackageTagHeader];
}

- (BOOL)onReciveHeadData:(NSData *)data;
{
    [self parseHeaderInfo:data];
    return YES;
}
- (BOOL)onReciveBodyData:(NSData *)data;
{
    return YES;
}

- (void)dealloc
{
    if (self.message)
    {
        CFRelease(self.message);
    }
}

#pragma mark - ParseHeader
//手动解析，也可以使用CFNetwork解析
- (void)parseHeaderInfo:(NSData *)data;
{
    NSString *headStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *headArray = [headStr componentsSeparatedByString:@"\r\n"];
    
    HLHTTPHeaderRequest * header = [HLHTTPHeaderRequest new];
    NSMutableDictionary *head = @{}.mutableCopy;
    
    __block BOOL res = YES;
    [headArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.length == 0)return ;
        if(idx == 0){
            NSArray *lineItems =  [obj componentsSeparatedByString:@" "];
            if(lineItems.count != 3) {
                *stop = YES;
                res = NO;
                return;
            }
            header.method = lineItems[0];
            header.path = [lineItems[1] stringByRemovingPercentEncoding];
            NSArray *array =  [lineItems[2] componentsSeparatedByString:@"/"];
            if(array.count != 2) {
                *stop = YES;
                res = NO;
            }
            header.protocol = array[0];
            header.version = array[1];
            return;
        }
        
        NSArray *headItems =  [obj componentsSeparatedByString:@": "];
        if(headItems.count != 2) return;
        [head setObject:[headItems[1] stringByRemovingPercentEncoding]
                 forKey:headItems[0]];
    }];
    
    header.host = head[@"Host"];
    header.headDic = head;
    
    
}


#pragma mark - work with CFNetwork
- (void)parseRequestWithCFNetwork:(NSData *)data;
{
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(NULL, YES);
    CFHTTPMessageAppendBytes(message, [data bytes], [data length]);
//    message = CFHTTPMessageCreateRequest(NULL,
//    (__bridge CFStringRef)method,
//    (__bridge CFURLRef)url,
//    (__bridge CFStringRef)version);
}

- (BOOL)isHeaderComplete
{
    return CFHTTPMessageIsHeaderComplete(self.message);
}

- (NSString *)version
{
    return (__bridge_transfer NSString *)CFHTTPMessageCopyVersion(self.message);
}

- (NSString *)method
{
    return (__bridge_transfer NSString *)CFHTTPMessageCopyRequestMethod(self.message);
}

- (NSURL *)url
{
    return (__bridge_transfer NSURL *)CFHTTPMessageCopyRequestURL(self.message);
}

- (NSInteger)statusCode
{
    return (NSInteger)CFHTTPMessageGetResponseStatusCode(self.message);
}

- (NSDictionary *)allHeaderFields
{
    return (__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields(self.message);
}

- (NSString *)headerField:(NSString *)headerField
{
    return (__bridge_transfer NSString *)CFHTTPMessageCopyHeaderFieldValue(self.message, (__bridge CFStringRef)headerField);
}

- (void)setHeaderField:(NSString *)headerField value:(NSString *)headerFieldValue
{
    CFHTTPMessageSetHeaderFieldValue(self.message,
                                     (__bridge CFStringRef)headerField,
                                     (__bridge CFStringRef)headerFieldValue);
}

- (NSData *)messageData
{
    return (__bridge_transfer NSData *)CFHTTPMessageCopySerializedMessage(self.message);
}

- (NSData *)body
{
    return (__bridge_transfer NSData *)CFHTTPMessageCopyBody(self.message);
}

- (void)setBody:(NSData *)body
{
    CFHTTPMessageSetBody(self.message, (__bridge CFDataRef)body);
}



@end
