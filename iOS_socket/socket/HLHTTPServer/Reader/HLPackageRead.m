//
//  HLPackageRead.m
//  iOS_socket
//
//  Created by hailong on 2020/01/30.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLPackageRead.h"
@interface HLPackageRead ()
@property(nonatomic,strong)NSMutableData *buffer;
@property(nonatomic,strong)NSData* terminator;

@property(nonatomic,assign)NSUInteger readLength;
@property(nonatomic,assign)NSUInteger bytesDone;
@end

@implementation HLPackageRead

+(instancetype)packageReadWithFixLength:(NSInteger)length;
{
    HLPackageRead * result = [HLPackageRead new];
    [result setupWithFixeLength:length];
    return result;
}
+(instancetype)packageReadWithTerminator:(NSString *)string;
{
    HLPackageRead * result = [HLPackageRead new];
    [result setupWithTerminator:string];
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
- (NSUInteger)readLengthForData:(NSUInteger)bytesAvailable;
{
    NSUInteger result = bytesAvailable;
    //固定长度
    if (self.readLength) {
        result = MIN(self.readLength - self.bytesDone, bytesAvailable);
    }
    
    return result;
}

- (BOOL)shouldUsePreBufferForDataLength:(NSUInteger)length;
{
    NSUInteger buffSize = [self.buffer length];
    NSUInteger buffUsed = self.bytesDone;
    
    return (buffSize - buffUsed) < length;
}

- (BOOL)hasDone;
{
    BOOL result = NO;
    if (self.readLength) {
        result = self.bytesDone == self.readLength;
    }else{
        NSUInteger termLength = [self.terminator length];
        uint8_t seq[termLength];
        const void *termBuf = [self.terminator bytes];
        
        NSUInteger bufLen = MIN(self.bytesDone, (termLength - 1));
        uint8_t *buf = (uint8_t *)[self.buffer mutableBytes] + self.bytesDone - bufLen;
        
        memcpy(seq, buf, bufLen);
        
        result = (memcmp(seq, termBuf, termLength) == 0);
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

- (void)didRead:(size_t)bytesRead;
{
    
}

- (void)didWrite:(size_t)bytesWritten;
{
    self.bytesDone = self.bytesDone + bytesWritten;
}

- (NSData *)bufferData;
{
    return self.buffer;
}
@end
