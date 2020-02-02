//
//  HLPackageRead.m
//  iOS_socket
//
//  Created by hailong on 2020/01/30.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLPackageRead.h"
@interface HLPackageRead ()
@property(nonatomic,strong)NSData* terminator;
@property(nonatomic,assign)NSUInteger readLength;
@end

@implementation HLPackageRead

+(instancetype)packageReadWithFixLength:(NSInteger)length tag:(NSInteger)tag;
{
    HLPackageRead * result = [HLPackageRead new];
    [result setupWithFixeLength:length];
    result.tag = tag;
    return result;
}
+(instancetype)packageReadWithTerminator:(NSString *)string tag:(NSInteger)tag;
{
    HLPackageRead * result = [HLPackageRead new];
    [result setupWithTerminator:string];
    result.tag = tag;
    return result;
}

- (void)setupWithFixeLength:(NSInteger)length;
{
    self.readLength = length;
    self.buffer = [[NSMutableData alloc] initWithLength:length];
}

- (void)setupWithTerminator:(NSString *)string;
{
    self.terminator = [string dataUsingEncoding:NSUTF8StringEncoding];
    self.buffer = [[NSMutableData alloc] initWithLength:0];
}


#pragma mark - 读取
- (BOOL)hasTerminator;
{
    return self.terminator != nil;
}

- (NSUInteger)readLengthForData:(uint8_t *)data availableLength:(NSUInteger)bytesAvailable;
{
    NSUInteger result = bytesAvailable;
    
    //两种情况，
    //1:固定长度
    //2:特殊结束符
    if (self.readLength) {
        result = MIN(self.readLength - self.bytesDone, bytesAvailable);
    }else{
        result = [self readLengthForData:data availableLength:bytesAvailable withTerminator:self.terminator];
    }
    
    return result;
}

//处理方式，特殊结束符的判断就用 memcmp 进行二进制比较
//判断的其实位置，就是当前已读数据的最后几位+data中的第一个字符开始组成一个结束符长度字符串，与结束符比较，
//依次往后移动一位，直到找到结束符，或者所有字符比完为止
- (NSUInteger)readLengthForData:(uint8_t *)data
                availableLength:(NSUInteger)bytesAvailable
                 withTerminator:(NSData *)terminator;
{
    NSUInteger result = bytesAvailable;
    NSUInteger termLength = [terminator length];
    NSUInteger preBufferLength = bytesAvailable;
    
    //加起来，连结束符的长度都不够
    if ((self.bytesDone + preBufferLength) < termLength){
        return preBufferLength;
    }
    
    const uint8_t *termBuf = [terminator bytes];
    uint8_t temp[termLength];
    
    NSUInteger readFromDoneLen = MIN(self.bytesDone, (termLength - 1));
    uint8_t *readFromDoneBuffer = (uint8_t *)[self readBuffer] + self.bytesDone - readFromDoneLen;
    
    NSUInteger readFromPreBufferLen = termLength - readFromDoneLen;
    const uint8_t *pre = data;
    
    NSUInteger loopCount = readFromDoneLen + bytesAvailable - termLength + 1;
    
    NSUInteger i;
    for (i = 0; i < loopCount; i++){
        if (readFromDoneLen > 0){
            // Combining bytes from buffer and preBuffer
            memcpy(temp, readFromDoneBuffer, readFromDoneLen);
            memcpy(temp + readFromDoneLen, pre, readFromPreBufferLen);
            
            if (memcmp(temp, termBuf, termLength) == 0){
                result = readFromPreBufferLen;
                break;
            }
            
            readFromDoneBuffer++;
            readFromDoneBuffer--;
            readFromPreBufferLen++;
        }else{
            // Comparing directly from preBuffer
            if (memcmp(pre, termBuf, termLength) == 0){
                NSUInteger preOffset = pre - data; // pointer arithmetic
                result = preOffset + termLength;
                break;
            }
            
            pre++;
        }
    }
    
    return result;
}

- (NSUInteger)readLengthForDataLength:(NSUInteger)bytesAvailable;
{
    NSUInteger result = 0;
    if (self.readLength) {
        result = MIN((self.readLength - self.bytesDone),bytesAvailable);
    }
    
    return result;
}

- (BOOL)shouldUsePreBufferForDataLength:(NSUInteger)length;
{
    NSUInteger buffSize = [self.buffer length];
    NSUInteger buffUsed = self.bytesDone;
    
    return (buffSize - buffUsed) < length;
}


#pragma mark -


- (void)ensureCapacityForAdditionalDataOfLength:(NSUInteger)bytesToRead;
{
    NSUInteger buffSize = [self.buffer length];
    NSUInteger buffUsed = self.bytesDone;
    
    NSUInteger buffSpace = buffSize - buffUsed;
    
    if (bytesToRead > buffSpace)
    {
        NSUInteger buffInc = bytesToRead - buffSpace;
        [self.buffer increaseLengthBy:buffInc];
    }
}

#pragma mark -

- (BOOL)hasDone;
{
    BOOL result = NO;
    if (self.readLength) {
        result = self.bytesDone == self.readLength;
    }else{
        NSUInteger termLength = [self.terminator length];
        const void *termBuf = [self.terminator bytes];
        uint8_t *buf = (uint8_t *)[self.buffer mutableBytes] + self.bytesDone - termLength;
        result = (memcmp(buf, termBuf, termLength) == 0);
    }
    
    return result;
}

- (uint8_t *)writeBuffer;
{
    return (uint8_t *)[self.buffer mutableBytes] + self.bytesDone;
}

- (uint8_t *)readBuffer;
{
    return (uint8_t *)[self.buffer mutableBytes];
}

@end
