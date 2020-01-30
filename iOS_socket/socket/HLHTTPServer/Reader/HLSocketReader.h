//
//  HLSocketReader.h
//  iOS_socket
//
//  Created by hailong on 2020/01/30.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPreBuffer.h"
#import "HLPackageRead.h"
/**
 *    HLSocketReader 负责从Socket中读数据
 *      处理读的规则，如读写到数据报文里，还是写到缓存里
 *      非线程安全
 *      两种情况，按照报文读取，读到prebuffer中
 */

NS_ASSUME_NONNULL_BEGIN

@interface HLSocketReader : NSObject

- (void)addPackageReader:(HLPackageRead *)reader;

- (NSUInteger)readLengthForEstimatedBytesAvailable:(NSUInteger)estimatedBytesAvailable
                                 readBufferPointer:(uint8_t *_Nullable*_Nullable)readBufferPointer;
- (void)didRead:(size_t)bytesWritten;

- (HLPackageRead *)hasDoneRead;

@end

NS_ASSUME_NONNULL_END
