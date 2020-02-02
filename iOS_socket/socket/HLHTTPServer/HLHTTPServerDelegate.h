//
//  HLHTTPServerDelegate.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//
#import "HLHTTPHeader.h"

@protocol HLHTTPRequestDelegate <NSObject>
@optional
- (void)requestHeadFinish:(HLHTTPHeaderRequest *)head;
- (void)requestBodyFinish:(HLHTTPHeaderRequest *)head;


- (BOOL)requestRefuse:(HLHTTPHeaderRequest *)head;
- (NSString *)requestBodyDataWritePath:(NSString *)path head:(HLHTTPHeaderRequest *)head;
- (void)requestBodyData:(NSData *)data
              atOffset:(u_int64_t)offset
              filePath:(NSString *)path
                  head:(HLHTTPHeaderRequest *)head;
- (void)requestBodyDataError:(NSError *)error
                       head:(HLHTTPHeaderRequest *)head;


@end

@protocol HLHTTPResponseDelegate <NSObject>

@optional
- (void)startLoadResource:(HLHTTPHeaderRequest *)head;
- (void)finishLoadResource:(HLHTTPHeaderRequest *)head;

- (BOOL)shouldUsedDelegate:(HLHTTPHeaderRequest *)head;
- (NSString *)redirect:(HLHTTPHeaderRequest *)head;
- (NSString *)resourceRelativePath:(HLHTTPHeaderRequest *)head;
- (BOOL)isDirectory:(HLHTTPHeaderRequest *)head;
- (BOOL)isResourceExist:(HLHTTPHeaderRequest *)head;
- (NSArray *)dirItemInfoList:(HLHTTPHeaderRequest *)head;
- (u_int64_t)resourceLength:(HLHTTPHeaderRequest *)head;
- (NSData *)readResource:(NSString *)path
               atOffset:(u_int64_t)offset
               length:(u_int64_t)length
               head:(HLHTTPHeaderRequest *)head;
@end

