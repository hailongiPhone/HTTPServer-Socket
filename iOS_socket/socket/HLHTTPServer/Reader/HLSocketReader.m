//
//  HLSocketReader.m
//  iOS_socket
//
//  Created by hailong on 2020/01/30.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLSocketReader.h"
#import "HLPreBuffer.h"
#import "HLPackageRead.h"
#import "HLReadBufferProtocal.h"

@interface HLSocketReader ()
@property (nonatomic,strong)NSMutableArray<HLPackageRead *> * packageReaders;
@property (nonatomic,strong)GCDAsyncSocketPreBuffer * preBuffer;

@property (nonatomic,strong)id<HLReadBufferProtocal> currentBuffer;
@end

@implementation HLSocketReader
#pragma mark - lifecycle
- (instancetype)init;
{
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup;
{
    self.packageReaders = [[NSMutableArray alloc] initWithCapacity:10];
    self.preBuffer = [[GCDAsyncSocketPreBuffer alloc] initWithCapacity:(1024 * 4)];
}

- (void)addPackageReader:(HLPackageRead *)reader;
{
    [self.packageReaders addObject:reader];
}

#pragma mark -
- (NSUInteger)readLengthForEstimatedBytesAvailable:(NSUInteger)estimatedBytesAvailable
                                 readBufferPointer:(uint8_t **)readBufferPointer;
{
    NSUInteger bytesToRead = estimatedBytesAvailable;
    HLPackageRead * currentReader = [self currentPackageReader];
    BOOL usePrebuffer = YES;
    
    if(currentReader){
        bytesToRead = [currentReader readLengthForData:estimatedBytesAvailable];
        usePrebuffer = [currentReader shouldUsePreBufferForDataLength:bytesToRead];
    }
    
    if (usePrebuffer) {
        self.currentBuffer = self.preBuffer;
        [self.preBuffer ensureCapacityForWrite:bytesToRead];
        *readBufferPointer = [self.preBuffer writeBuffer];
    }else{
        self.currentBuffer = currentReader;
        [self.packageReaders removeObject:currentReader];
        *readBufferPointer = [currentReader writeBuffer];
    }
    
    return bytesToRead;
}

- (void)didRead:(size_t)bytesWritten;
{
    [self.currentBuffer didWrite:bytesWritten];
}

- (HLPackageRead *)currentPackageReader;
{
    if (!self.packageReaders) {
        return nil;
    }
    return [self.packageReaders firstObject];
}

- (HLPackageRead *)hasDoneRead;
{
    if (![self.currentBuffer isKindOfClass:[HLPackageRead class]]) {
        return nil;
    }
    
    HLPackageRead * read = (HLPackageRead * )self.currentBuffer;
    return [read hasDone] ? read : NULL;
}
@end
