//
//  HLSocketWriter.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPackageWriter.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSocketWriter : NSObject
- (void)addPackageWriter:(HLPackageWriter *)package;
- (NSInteger)writeLenthWriteBufferPointer:(uint8_t *_Nullable*_Nullable)readBufferPointer;
- (void)didWrite:(size_t)bytesWritten;

- (HLPackageWriter *)extractDoneWrite;
@end

NS_ASSUME_NONNULL_END
