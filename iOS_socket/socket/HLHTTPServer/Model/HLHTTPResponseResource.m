//
//  HLHTTPResponseResource.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPResponseResource.h"

@implementation HLHTTPResponseResource
+(instancetype)responseHandlerWithRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
{
    HLHTTPResponseResource * tmp = [HLHTTPResponseResource new];
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

- (NSData *) body;
{
    NSString * body = @"<html>\
    <head>\
    <title>HLHTTPServer测试界面</title>\
    <meta http-equiv='content-type' content='txt/html; charset=utf-8' /> \
    </head>\
    <body>\
    <p>body 上传图片文件可以直接在App中展示。</p>\
    <form action='hl' method='POST' enctype='multipart/form-data'>\
        <p><input type='file' name='upload'></p>\
        <p><input type='submit' value='submit'></p>\
    </form>\
    </body>\
    </html>";
    
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}
@end
