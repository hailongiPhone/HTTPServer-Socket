//
//  HLHTTPRequestHandle.m
//  iOS_socket
//
//  Created by hailong on 2020/02/02.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPRequestHandler.h"
#import "HLMultipartBodyParser.h"

@interface HLHTTPRequestHandler ()
@property(nonatomic,strong) HLHTTPRequest * request;
@property(nonatomic,assign) CFHTTPMessageRef message;
@property(nonatomic,assign) BOOL waitingBodyData;

@property(nonatomic,strong) HLMultipartBodyParser * bodyParser;
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
//    [self parseRequestWithCFNetwork:data];
    
    self.request.header = self.requestHeader;
    self.waitingBodyData = [self hasBody];
    return YES;
}
- (BOOL)onReciveBodyData:(NSData *)data;
{
    if (!self.bodyParser) {
        self.bodyParser = [HLMultipartBodyParser parseWithHeader:self.requestHeader];
    }
    [self.bodyParser addData:data];
    
    self.request.body = self.requestBody;
    
    self.waitingBodyData = NO;
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
- (HLBody *)requestBody;
{
    if (!self.bodyParser) {
        return nil;
    }
    
    return [self.bodyParser requestBody];
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

//- (HLHTTPRequest *)request;
//{
//    return self.request;
//}
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
    HLHTTPHeaderRequest * header = [HLHTTPHeaderRequest new];
    [header parseFromAllData:data];
    
    [[self lazyRequest] setHeader:header];
}

//更新上传文件的信息，body的分割符号
//- (void)updateUploadFileHeaderInfo:(HLHTTPHeaderRequest *)headerInfo;
//{
//
//    if(![headerInfo.method isEqualToString:@"POST"]){
//        return;
//    }
//
//    NSString * contentType = [headerInfo.headDic valueForKey:@"Content-Type"];
//    NSArray * array = [contentType componentsSeparatedByString:@";"];
//    NSString * type = array[0];
//    //上传文件必须是multipart/form-data，并且有额外参数boundary
//    //Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryWcBrx73QHWvIBGTK
////    Content-Length: 35840
//    if ([array count] <= 1 || ![type isEqualToString:@"multipart/form-data"]) {
//        return;
//    }
//
//    //找boundary
//    NSInteger count = [array count];
//    for (NSInteger i = 1; i < count; i++) {
//        NSString * param = [array objectAtIndex:i];
//        NSArray * array = [param componentsSeparatedByString:@"="];
//        if ([array[0] isEqualToString:@"boundary"]) {
//            [headerInfo setBoundary:array[0]];
//            break;
//        }
//    }
//}

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

    header.lineMap = [[self allHeaderFields] mutableCopy];
    
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
- (void)parseBody:(NSData *)body withBoundary:(NSString *)boundary
{
    
}
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
