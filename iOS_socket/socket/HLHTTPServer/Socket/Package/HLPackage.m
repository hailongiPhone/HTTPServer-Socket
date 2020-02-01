//
//  HLPackage.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLPackage.h"

@implementation HLPackage
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
