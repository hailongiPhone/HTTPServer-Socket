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

/**
 *  Socket的写策略，如果不确定要读什么（没有指定的报文读取策略），就放到preBuffer中缓存，
 *    如果有确定的报文读取策略，就直接从socket读取到对应的报文读取策略中
 *
 *  HLPackageRead 用于读取一个有效的报文
 *      指定报文读写策略，如定长读取，特殊字符串读取
 *         报文数据
 *
 *  报文读取流程
 *       （因为从preBuffer中读取，报文还要多一次数据拷贝，所以尽可能直接从socket中读取）
 *       从缓存Prebuffer中读取，如果为空，从socket中直接读取
*/

NS_ASSUME_NONNULL_BEGIN

@interface HLSocketReader : NSObject

- (void)addPackageReader:(HLPackageRead *)reader;

- (NSUInteger)readLengthForEstimatedBytesAvailable:(NSUInteger)estimatedBytesAvailable
                                 readBufferPointer:(uint8_t *_Nullable*_Nullable)readBufferPointer;
- (void)didRead:(size_t)bytesWritten;

- (HLPackageRead *)extractDoneRead;

@end

NS_ASSUME_NONNULL_END
