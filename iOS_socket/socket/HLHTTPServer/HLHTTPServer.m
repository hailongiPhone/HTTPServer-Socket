//
//  HLHTTPServer.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPServer.h"
#import "HLSocketServer.h"
#import "HLSocketConnect.h"

typedef enum : NSUInteger {
    PackageTypeTest,
} PackageType;

@interface HLHTTPServer () <HLSocketServerDelegate>

@property (nonatomic,strong)HLSocketServer * socketServer;
@property (nonatomic,strong)dispatch_queue_t socketCallbackQueue;
@end

@implementation HLHTTPServer
-(instancetype)initWithPort:(NSInteger)port;
{
    if(self = [super init]){
        self->_port = port;
        [self setupSocketServer];
    }
    
    return self;
    
}

-(void)setDocumentRoot:(NSString*)path;
{
    
}
#pragma mark - Socket
- (void)setupSocketServer;
{
    self.socketServer = [HLSocketServer new];
    self.socketCallbackQueue = dispatch_queue_create("HLHTTPServerSocetCallbackQueue", NULL);
    [self.socketServer setDelegate:self
                     callbackQueue:self.socketCallbackQueue];
    
    [self.socketServer setupMainReactor:self->_port];
    
    
}

- (void) connect:(HLSocketConnect *)connect readPackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    switch (tag) {
        case PackageTypeTest:
            NSLog(@"%@",[NSString stringWithUTF8String:[data bytes]]);
            break;
            
        default:
            break;
    }
}

- (void) connect:(HLSocketConnect *)connect writePackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    
}

- (void) connect:(HLSocketConnect *)connect;
{
    [connect readPackage:[HLPackageRead packageReadWithFixLength:100]
              packageTag:PackageTypeTest];
}

- (void) connectClosed:(HLSocketConnect *)connect;
{
    
}
@end
