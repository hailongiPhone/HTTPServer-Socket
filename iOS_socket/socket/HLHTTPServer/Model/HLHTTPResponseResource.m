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
    self.responseHeader = [self headerForRequestHeader:requestHeader];
    self.responseHeader.contentLength = [body length];
    self.body = body;
}

- (HLHTTPHeaderResponse *)headerForRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
{
    NSDate *date = [NSDate date];
    NSString *dataStr = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle];
    NSDictionary *dic = @{
                          @"Date"   : dataStr,
                          @"Server" : @"HLHTTPServer",
                          @"Accept-Ranges": @"bytes"
                          };
    
    HLHTTPHeaderResponse * header = [HLHTTPHeaderResponse new];
    header.headDic = dic.mutableCopy;
    header.protocol = requestHeader.protocol;
    header.version = requestHeader.version;
    header.stateCode = [requestHeader hasRangeHead] ? 206 : 200;
    header.stateDesc = @"OK";
    
    return header;
}

- (HLPackageWriter *)writerPackageForHeaderInfo;
{
    return [HLPackageWriter packageWithData:[self.responseHeader dataOfHeader] tag:HLResponsePackageTagHeader];
}
- (HLPackageWriter *)writerPackageBody;
{
    return [HLPackageWriter packageWithData:self.body tag:HLResponsePackageTagBody];
}

- (NSData *) body;
{
    NSString * body = @"<html>\
    <head>\
    <title>我的第一个 HTML 页面</title>\
    <meta http-equiv='content-type' content='txt/html; charset=utf-8' /> \
    </head>\
    <body>\
    <p>body 元素的内容会显示在浏览器中。</p>\
    <p>title 元素的内容会显示在浏览器的标题栏中。</p>\
    <form action='hl' method='post' enctype='multipart/form-data'>\
        <p><input type='file' name='upload'></p>\
        <p><input type='submit' value='submit'></p>\
    </form>\
    </body>\
    </html>";
    
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}
@end
