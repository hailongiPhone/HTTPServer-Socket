//
//  BaseSocket.h
//  iOS_socket
//
//  Created by hailong on 2020/01/13.
//  Copyright © 2020 HL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseSocket : NSObject

- (void) setupServerTCP;
- (void) setupClinetTCP;


- (void) setupServerUDP;
- (void) setupClinetUDP;

- (void) setupServerLocalIPCStream;
- (void) setupClinetLocalIPCStream;

- (void) setupServerLocalIPCDgram;
- (void) setupClinetLocalIPCDgram;
@end
