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
#import "HLHTTPConnect.h"



@interface HLHTTPServer () <HLSocketServerDelegate,HLHTTPConnectDelegate>

@property (nonatomic,strong)HLSocketServer * socketServer;
@property (nonatomic,strong)dispatch_queue_t socketCallbackQueue;

@property (nonatomic,strong)NSMutableDictionary * connectMap;
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
    self.connectMap = [[NSMutableDictionary alloc] initWithCapacity:100];
    
    self.socketServer = [HLSocketServer new];
    self.socketCallbackQueue = dispatch_queue_create("HLHTTPServerSocetCallbackQueue", NULL);
    [self.socketServer setDelegate:self
                     callbackQueue:self.socketCallbackQueue];
    
    [self.socketServer setupMainReactor:self->_port];
    
    
}

- (void) connect:(HLSocketConnect *)connect readPackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    HLHTTPConnect * httpConnect =  [self httpConnectForSocketConnect:connect];
    [httpConnect readPackageData:data packageTag:tag];
}

- (void) connect:(HLSocketConnect *)connect writePackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    NSLog(@"data = %@",data);
    
    HLHTTPConnect * httpConnect =  [self httpConnectForSocketConnect:connect];
    [httpConnect writeDonePackageTag:tag];
}

- (void) connect:(HLSocketConnect *)connect;
{
    HLHTTPConnect * httpConnect =  [self httpConnectForSocketConnect:connect];
    [httpConnect connect];
}

- (void) connectClosed:(HLSocketConnect *)connect;
{
    HLHTTPConnect * httpConnect =  [self httpConnectForSocketConnect:connect];
    [httpConnect disconnect];
    [self.connectMap removeObjectForKey:connect];
}

#pragma mark - requesst
-(HLHTTPResponse*) responseForRequest:(HLHTTPRequest*)request;
{
    HLHTTPResponse * response = nil;;
    if (self.delegate && [self.delegate respondsToSelector:@selector(responseForRequest:)]) {
        response = [self.delegate responseForRequest:request];
    }else{
        response = [HLHTTPResponse responseHandlerWithRequestHeader:request.header];
    }
    
    return response;
}


#pragma mark - Connect map
- (HLHTTPConnect *) httpConnectForSocketConnect:(HLSocketConnect *)socketConnect;
{
    HLHTTPConnect * httpConnect = [self.connectMap objectForKey:socketConnect];
    if (!httpConnect) {
        httpConnect = [[HLHTTPConnect alloc] initWith:socketConnect];
        httpConnect.delegate = self;
        [self.connectMap setObject:httpConnect forKey:socketConnect];
    }
    
    return httpConnect;
}
@end
