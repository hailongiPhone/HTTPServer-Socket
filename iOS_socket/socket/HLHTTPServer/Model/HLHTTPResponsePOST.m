//
//  HLHTTPResponsePOST.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPResponsePOST.h"
#import "HLHTTPResponse.h"

@implementation HLHTTPResponsePOST
+ (HLHTTPResponse *)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
{
    HLHTTPResponsePOST * tmp = [HLHTTPResponsePOST new];
    [tmp setup:requestHeader];
    return tmp;
}

- (void) setup:(HLHTTPHeaderRequest *)requestHeader;
{
    
    self.requestHeader = requestHeader;
    NSData * body = [self body];
    self.responseHeader = [HLHTTPHeaderResponse headerForRequestHeader:requestHeader];
    self.responseHeader.contentLength = [body length];
    self.body = body;
}

- (HLPackageWriter *)writerPackage;
{
    NSData * header = [self.responseHeader achiveData];
    NSMutableData * d = [NSMutableData new];
    [d appendData:header];
    if(self.body){
        [d appendData:self.body];
    }
    
    return [HLPackageWriter packageWithData:d tag:HLResponsePackageTagHeader];
}

- (HLPackageWriter *)writerPackageForHeaderInfo;
{
    return [HLPackageWriter packageWithData:[self.responseHeader achiveData] tag:HLResponsePackageTagHeader];
}
- (HLPackageWriter *)writerPackageBody;
{
    return [HLPackageWriter packageWithData:self.body tag:HLResponsePackageTagBody];
}

#pragma mark -
- (NSData *) body;
{
    NSString * body = @"<html>\
    <head>\
    <title>上传成功</title>\
    <meta http-equiv='content-type' content='txt/html; charset=utf-8' /> \
    </head>\
    <body>\
    <p>body 接收到文件。</p>\
    <p>title 接收到文件啦啦啦。</p>\
    <form action='hl' method='POST' enctype='multipart/form-data'>\
        <p><input type='file' name='upload'></p>\
        <p><input type='submit' value='submit'></p>\
    </form>\
    </body>\
    </html>";
    
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}
@end
