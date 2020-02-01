//
//  HLPackageWriter.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLPackageWriter.h"

@interface HLPackageWriter ()
@property(nonatomic,strong)NSData *buffer;
@property(nonatomic,assign)NSUInteger bytesDone;
@end

@implementation HLPackageWriter

+ (instancetype)packageWithData:(NSData *)data tag:(NSInteger)tag;
{
    HLPackageWriter * tmp = [[HLPackageWriter alloc] initWithData:data tag:tag];
    return tmp;
}

- (instancetype)initWithData:(NSData *)data tag:(NSInteger)tag;
{
    if ((self = [super init])) {
        self.buffer = data;
        self.tag = tag;
    }
    return self;
}

- (NSUInteger)lengthToWrite;
{
    return [self.buffer length] - self.bytesDone;
}

- (BOOL)hasDone;
{
    return self.bytesDone >= [self.buffer length];
}

- (uint8_t *)writeBuffer;
{
    return (uint8_t *)[self.buffer bytes] + self.bytesDone;
}

- (uint8_t *)readBuffer;
{
    return (uint8_t *)[self.buffer bytes] + self.bytesDone;
}


- (void)didRead:(size_t)bytesRead;
{
    self.bytesDone = self.bytesDone + bytesRead;
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
