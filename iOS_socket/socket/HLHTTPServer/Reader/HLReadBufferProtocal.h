//
//  HLReadBufferProtocal.h
//  iOS_socket
//
//  Created by hailong on 2020/01/30.
//  Copyright © 2020 HL. All rights reserved.
//

#ifndef HLReadBufferProtocal_h
#define HLReadBufferProtocal_h

@protocol HLReadBufferProtocal <NSObject>

- (uint8_t *)writeBuffer;
- (uint8_t *)readBuffer;

- (void)didRead:(size_t)bytesRead;
- (void)didWrite:(size_t)bytesWritten;

@end

#endif /* HLReadBufferProtocal_h */
