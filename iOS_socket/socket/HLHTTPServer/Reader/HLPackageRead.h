//
//  HLPackageRead.h
//  iOS_socket
//
//  Created by hailong on 2020/01/30.
//  Copyright © 2020 HL. All rights reserved.
//

/**
 *
 *  数据报读取策略
 *      1：固定长度
 *      2：特殊字符串
 */

#import <Foundation/Foundation.h>
#import "HLReadBufferProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLPackageRead : NSObject <HLReadBufferProtocal>
{
    @public
//    NSMutableData *buffer;
    
//    NSUInteger startOffset;
//    NSUInteger bytesDone;
//    NSUInteger maxLength;
    
    NSTimeInterval timeout;
    
//    NSUInteger readLength;
    
//    NSData *terminator;
    
    BOOL bufferOwner;
    NSUInteger originalBufferLength;
//    long tag;
}

@property(nonatomic,assign)NSInteger tag;

+(instancetype)packageReadWithFixLength:(NSInteger)length;
+(instancetype)packageReadWithTerminator:(NSString *)string;

- (BOOL)hasTerminator;
- (NSUInteger)readLengthForData:(uint8_t *)data availableLength:(NSUInteger)bytesAvailable;
- (NSUInteger)readLengthForDataLength:(NSUInteger)bytesAvailable;
- (BOOL)shouldUsePreBufferForDataLength:(NSUInteger)length;
- (BOOL)hasDone;

- (void)ensureCapacityForAdditionalDataOfLength:(NSUInteger)bytesToRead;

- (uint8_t *)writeBuffer;
- (uint8_t *)readBuffer;
- (void)didRead:(size_t)bytesRead;
- (void)didWrite:(size_t)bytesWritten;

- (NSData *)bufferData;

@end

NS_ASSUME_NONNULL_END
