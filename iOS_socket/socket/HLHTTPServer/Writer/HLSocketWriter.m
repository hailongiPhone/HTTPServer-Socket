//
//  HLSocketWriter.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLSocketWriter.h"

@interface HLSocketWriter ()
@property (nonatomic,strong) NSMutableArray * packageList;

@property (nonatomic,strong) HLPackageWriter * currentPackageTemp;
@end

@implementation HLSocketWriter

- (instancetype)init;
{
    if (self=[super init]) {
        [self setup];
    }
    return self;
}

- (void)setup;
{
    self.packageList = [[NSMutableArray alloc] initWithCapacity:10];
}


- (void)addPackageWriter:(HLPackageWriter *)package;
{
    [self.packageList addObject:package];
}

- (NSInteger)writeLenthWriteBufferPointer:(uint8_t *_Nullable*_Nullable)readBufferPointer;
{
    NSInteger result = 0;
    
    HLPackageWriter * package = [self currentPackage];
    if (package) {
        result = [package lengthToWrite];
        *readBufferPointer = [package readBuffer];
    }
    return result;
}

- (HLPackageWriter *)currentPackage
{
    if (self.currentPackageTemp) {
        return self.currentPackageTemp;
    }
    
    if ([self.packageList count] < 1) {
        return nil;
    }
    
    self.currentPackageTemp = [self.packageList firstObject];
    [self.packageList removeObject:self.currentPackageTemp];
    
    return self.currentPackageTemp;
}

- (void)didWrite:(size_t)bytesWritten;
{
    if (!self.currentPackageTemp) {
        return;
    }
    
    [self.currentPackageTemp didRead:bytesWritten];
}

- (HLPackageWriter *)extractDoneWrite;
{
    HLPackageWriter * package = [self currentPackage];
    if ([package hasDone]) {
        self.currentPackageTemp = nil;
    }else{
        package = nil;
    }
    return package;
}

@end
