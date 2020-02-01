//
//  HLPackageWriter.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HLReadBufferProtocal.h"
NS_ASSUME_NONNULL_BEGIN

@interface HLPackageWriter : NSObject
@property(nonatomic,assign)NSInteger tag;

+ (instancetype)packageWithData:(NSData *)data tag:(NSInteger)tag;
- (instancetype)initWithData:(NSData *)data tag:(NSInteger)tag;

- (NSUInteger)lengthToWrite;

- (BOOL)hasDone;

- (uint8_t *)writeBuffer;
- (uint8_t *)readBuffer;

- (void)didRead:(size_t)bytesRead;
- (void)didWrite:(size_t)bytesWritten;

- (NSData *)bufferData;
@end

NS_ASSUME_NONNULL_END
