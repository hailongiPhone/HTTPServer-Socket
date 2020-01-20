//
//  HLHTTPServer.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPServer.h"
#import "HLSocketServer.h"

@interface HLHTTPServer ()

@property (nonatomic,strong)HLSocketServer * socketServer;

@end

@implementation HLHTTPServer
-(instancetype)initWithPort:(NSInteger)port;
{
    if(self = [super init]){
        self->_port = port;
    }
    
    return self;
    
}
#pragma mark - Socket
- (void)setupSocketServer;
{
    self.socketServer = [HLSocketServer new];
    
}
@end
