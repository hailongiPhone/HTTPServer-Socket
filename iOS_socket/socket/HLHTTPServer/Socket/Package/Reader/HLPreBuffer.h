//
//  HLPreBuffer.h
//  iOS_socket
//
//  Created by hailong on 2020/01/21.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLReadBufferProtocal.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Socket的写策略，如果不确定要读什么（没有指定的报文读取策略），就放到preBuffer中缓存，
 *  如果有确定的报文读取策略，就直接从socket读取到对应的报文读取策略中，可以肯定的是读取到报文读取策略中最快
 *
 *  PreBuffer 用于数据缓存用于缓存套接字读的数据
 *  目标是尽可能减少内存的使用
 *
 *      执行流程 socket会一直收到数据，由于要分报文进行读取解析，并不会一次解析完成，所以preBuffer用于缓存socket接收的read出来的数据
 *      类似Stream的概念，只是底层的实现要考虑到内存的使用情况
 *      由于使用了malloc realloc，实际上内存使用是一值扩展的
 *
 *      对内存大小的操作主要是在写，写之前要确保有足够的内存，
 *              写操作流程
 *
 *
 */

@interface GCDAsyncSocketPreBuffer : NSObject<HLReadBufferProtocal>
{
    uint8_t *preBuffer;     //实际缓冲
    size_t preBufferSize;
    
    uint8_t *readPointer;       //指向的是实际地址，不是偏移量
    uint8_t *writePointer;
}

- (id)initWithCapacity:(size_t)numBytes;

- (size_t)availableBytes;
- (uint8_t *)readBuffer;

- (void)ensureCapacityForWrite:(size_t)numBytes;
- (size_t)availableSpace;
- (uint8_t *)writeBuffer;

- (void)didRead:(size_t)bytesRead;
- (void)didWrite:(size_t)bytesWritten;

- (void)reset;
@end

NS_ASSUME_NONNULL_END
