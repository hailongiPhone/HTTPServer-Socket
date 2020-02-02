//
//  HLHTTPResponse.h
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPackageWriter.h"
#import "HLHTTPHeader.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HLResponsePackageTag) {
    HLResponsePackageTagHeader,
    HLResponsePackageTagBody,
};

@interface HLHTTPResponse : NSObject
@property (nonatomic,strong) HLHTTPHeaderRequest * requestHeader;
@property (nonatomic,strong) HLHTTPHeaderResponse * responseHeader;
@property (nonatomic,strong) NSData * body;
- (HLPackageWriter *)writerPackageForHeaderInfo;
- (HLPackageWriter *)writerPackageBody;
@end

NS_ASSUME_NONNULL_END
