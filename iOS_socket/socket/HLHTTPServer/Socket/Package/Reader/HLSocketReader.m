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
    HLPackageRead * currentPackageReader = nil;
    BOOL usePrebuffer = YES;
    
    if ([self.preBuffer availableBytes] <= 0) {
        currentPackageReader =  [self firstPackageReader];
    }
    
    if(currentPackageReader){
        usePrebuffer = [currentPackageReader shouldUsePreBufferForDataLength:bytesToRead];
    }
    
    if (usePrebuffer) {
        self.currentBuffer = self.preBuffer;
        [self.preBuffer ensureCapacityForWrite:bytesToRead];
        *readBufferPointer = [self.preBuffer writeBuffer];
    }else{
        bytesToRead = [currentPackageReader readLengthForDataLength:bytesToRead];
        
        self.currentBuffer = currentPackageReader;
        [self.packageReaders removeObject:currentPackageReader];
        *readBufferPointer = [currentPackageReader writeBuffer];
    }
    
    return bytesToRead;
}

- (void)didRead:(size_t)bytesWritten;
{
    [self.currentBuffer didWrite:bytesWritten];
}

- (HLPackageRead *)firstPackageReader;
{
    if (!self.packageReaders) {
        return nil;
    }
    return [self.packageReaders firstObject];
}

- (HLPackageRead *)extractDoneRead;
{
    HLPackageRead * read = (HLPackageRead * )self.currentBuffer;
    
    //如果保存在preBuffer中
    if (![read isKindOfClass:[HLPackageRead class]]) {
        read = [self firstPackageReader];
        
        if (!read) {
            NSLog(@"NO Package Reader");
            return nil;
        }
        
        [self packageReader:read readFromPreBuffer:self.preBuffer];
    }
    
    BOOL hasDone = [read hasDone];
    
    if (hasDone) {
        NSLog(@"Package Reader Done = %@",read);
        if (read == self.currentBuffer) {
            self.currentBuffer = nil;
        }else{
            [self.packageReaders removeObject:read];
        }
    }else{
        NSLog(@"Package Reader NOT Done = %@ PreBuffer = %ld",read,[self.preBuffer availableBytes]);
        read = nil;
    }
    return  read;
}

//读取的过程，首先确定长度，然后分配内存，在拷贝数据
- (void)packageReader:(HLPackageRead *)reader readFromPreBuffer:(GCDAsyncSocketPreBuffer *)preBuffer;
{
    if (!reader) {
        return;
    }
    
    if ([preBuffer availableBytes] < 1) {
        return;
    }
    
    //两种情况，特定长度，特殊结束符
    NSUInteger bytesToCopy = 0;
    
    bytesToCopy = [reader readLengthForData:[preBuffer readBuffer] availableLength:[preBuffer availableBytes]];
    
    [reader ensureCapacityForAdditionalDataOfLength:bytesToCopy];
    
    //数据拷贝
    uint8_t *buffer = [reader writeBuffer];
    memcpy(buffer, [preBuffer readBuffer], bytesToCopy);
    
    [preBuffer didRead:bytesToCopy];
    [reader didWrite:bytesToCopy];
}
@end
