//
//  HLPackageWriter.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HLPackage.h"
NS_ASSUME_NONNULL_BEGIN

@interface HLPackageWriter : HLPackage


+ (instancetype)packageWithData:(NSData *)data tag:(NSInteger)tag;
- (instancetype)initWithData:(NSData *)data tag:(NSInteger)tag;

- (NSUInteger)lengthToWrite;

@end

NS_ASSUME_NONNULL_END
