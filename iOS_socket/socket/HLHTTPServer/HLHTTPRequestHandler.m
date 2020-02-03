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
@property(nonatomic,assign) BOOL waitingBodyData;
@end

@implementation HLHTTPRequestHandler


- (HLPackageRead *)readPackageForHeaderInfo;
{
    return [HLPackageRead packageReadWithTerminator:@"\r\n\r\n" tag:HLRequestPackageTagHeader];
}

- (HLPackageRead *)readPackageBody;
{
    if (![self hasBody]) {
        return nil;
    }
    return [HLPackageRead packageReadWithFixLength:[[self lazyRequest] header].contentLength
                                               tag:HLRequestPackageTagBody];
}

- (BOOL)onReciveHeadData:(NSData *)data;
{
    [self parseHeaderInfo:data];
    self.waitingBodyData = [self hasBody];
    return YES;
}
- (BOOL)onReciveBodyData:(NSData *)data;
{
    [self bodySaveAsFile:data];
    return YES;
}

- (void)dealloc
{
    if (self.message)
    {
        CFRelease(self.message);
    }
}

- (BOOL)hasBody;
{
    return [[[self lazyRequest] header] hasBody];
}

- (BOOL)hasDone;
{
    BOOL hasDone = [[self lazyRequest] header] != nil;
    if (self.hasBody) {
        hasDone = !self.waitingBodyData;
    }
    
    return hasDone;
}

- (HLHTTPHeaderRequest *)requestHeader;
{
    return [[self lazyRequest] header];
}
#pragma mark - ParseHeader
//手动解析，也可以使用CFNetwork解析
/*
GET /minion.png HTTP/1.1 // 包含了请求方法、请求资源路径、HTTP协议版本
Host: 120.25.226.186:32812 // 客户端想访问的服务器主机地址
User-Agent: Mozilla/5.0 // 客户端的类型，客户端的软件环境
Accept: text/html // 客户端所能接收的数据类型
Accept-Language: zh-cn // 客户端的语言环境
Accept-Encoding: gzip // 客户端支持的数据压缩格式
*/

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
    
    NSString * length = [head valueForKey:@"Content-Length"];
    if (length) {
        header.contentLength = strtoull([length UTF8String], NULL, 0);
    }
    
    header.headDic = head;
    
    [[self lazyRequest] setHeader:header];
}

- (HLHTTPRequest *)lazyRequest;
{
    if (!self.request) {
        self.request = [HLHTTPRequest new];
    }
    
    return self.request;
}

#pragma mark - work with CFNetwork
- (void)parseRequestWithCFNetwork:(NSData *)data;
{
    if(!self.message){
        self.message = CFHTTPMessageCreateEmpty(NULL, YES);
        //    message = CFHTTPMessageCreateRequest(NULL,
        //    (__bridge CFStringRef)method,
        //    (__bridge CFURLRef)url,
        //    (__bridge CFStringRef)version);
    }
    
    CFHTTPMessageAppendBytes(self.message, [data bytes], [data length]);

    if (!CFHTTPMessageIsHeaderComplete(self.message)) {
        return;
    }
    HLHTTPHeaderRequest * header = [HLHTTPHeaderRequest new];
    header.method = [self method];
    header.path = [[self url] absoluteString];
    header.version = [self version];
    
    header.host = [self headerField:@"Host"];
    NSString * length = [self headerField:@"Content-Length"];
    if (length) {
        header.contentLength = strtoull([length UTF8String], NULL, 0);
    }
    header.headDic = [self allHeaderFields];
    
    [[self lazyRequest] setHeader:header];
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


#pragma mark - Body
//最简单处理--保存到一个默认文件夹
- (void)bodySaveAsFile:(NSData *)body;
{
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    HLHTTPHeaderRequest * header = [[self lazyRequest] header];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:header.fileName];
    
    BOOL written = [body writeToFile:path options:NSDataWritingAtomic error:nil];
    NSLog(@"written = %d",written);
    
    self.waitingBodyData = NO;
}
@end
