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


@end
