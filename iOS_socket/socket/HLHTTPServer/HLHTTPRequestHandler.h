//
//  HLHTTPRequestHandle.h
//  iOS_socket
//
//  Created by hailong on 2020/02/02.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPackageRead.h"
#import "HLHTTPRequest.h"
#import "HLHTTPHeader.h"

/**
 * HLHTTPRequestHandler 负责解析request
 *  header是一次性直接获取所有header信息--也可以按照header格式，一行一行获取再解析
 * body
 */

typedef NS_ENUM(NSUInteger, HLRequestPackageTag) {
    HLRequestPackageTagHeader,
    HLRequestPackageTagBody,
};

NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPRequestHandler : NSObject
- (HLPackageRead *)readPackageForHeaderInfo;
- (HLPackageRead *)readPackageBody;

- (BOOL)onReciveHeadData:(NSData *)data;
- (BOOL)onReciveBodyData:(NSData *)data;

- (BOOL)hasBody;

- (BOOL)hasDone;

- (HLHTTPHeaderRequest *)requestHeader;
@end

NS_ASSUME_NONNULL_END
