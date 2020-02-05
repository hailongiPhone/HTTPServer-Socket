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
#import "HLPackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLPackageRead : HLPackage
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
@property (nonatomic,assign) NSTimeInterval readPackageTimeout;

+(instancetype)packageReadWithFixLength:(NSInteger)length tag:(NSInteger)tag;
+(instancetype)packageReadWithTerminator:(NSString *)string tag:(NSInteger)tag;

- (BOOL)hasTerminator;
- (NSUInteger)readLengthForData:(uint8_t *)data availableLength:(NSUInteger)bytesAvailable;
- (NSUInteger)readLengthForDataLength:(NSUInteger)bytesAvailable;
- (BOOL)shouldUsePreBufferForDataLength:(NSUInteger)length;


- (void)ensureCapacityForAdditionalDataOfLength:(NSUInteger)bytesToRead;


@end

NS_ASSUME_NONNULL_END
