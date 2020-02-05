//
//  HLHTTPConnect.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPConnect.h"
#import "HLPackageRead.h"
#import "HLHTTPRequestHandler.h"
#import "HLHTTPResponseHandler.h"
#import "HLHTTPResponse.h"



@interface HLHTTPConnect ()
@property (nonatomic,strong) HLSocketConnect * socketConnect;
@property (nonatomic,strong) HLHTTPRequestHandler * requestHandler;
@property (nonatomic,strong) HLHTTPResponseHandler * responseHandler;
@end


@implementation HLHTTPConnect

- (instancetype)initWith:(HLSocketConnect *)socketConnect;
{
    if (self =[super init]) {
        self.socketConnect = socketConnect;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"HLHTTPConnect dealloc");
}

- (void)connect;
{
    self.requestHandler = [HLHTTPRequestHandler new];
    
    HLPackageRead * packageHeader = [self.requestHandler readPackageForHeaderInfo];
    //从socketConnect的代理线程，回到socketConnect的工作线程
    [self.socketConnect readPackage:packageHeader timeout:1];
}

- (void)disconnect;
{
    self.socketConnect = nil;
}

- (void)readPackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    switch (tag) {
        case HLRequestPackageTagHeader:
        {
            NSLog(@"Header == %@,length=%ld",[NSString stringWithUTF8String:[data bytes]],[data length]);
            [self.requestHandler onReciveHeadData:data];
            HLPackageRead * packageBody = [self.requestHandler readPackageBody];
            if (packageBody) {
                [self.socketConnect readPackage:packageBody timeout:1];
            }else{
                [self tryToReplyToHTTPRequest];
            }
        }
            break;
        case HLRequestPackageTagBody:
        {
            NSLog(@"Body string == %@,length=%ld",[NSString stringWithUTF8String:[data bytes]],[data length]);
            [self.requestHandler onReciveBodyData:data];
            
            [self tryToReplyToHTTPRequest];
        }
            break;
        default:
            break;
    }
}

- (void)writeDonePackageTag:(NSInteger)tag;
{
    NSLog(@"writeDonePackageTag %ld",tag);
    if (tag == HLResponsePackageTagBody) {

        if ([[self.requestHandler requestHeader] keepAlive]) {
            HLPackageRead * packageHeader = [self.requestHandler readPackageForHeaderInfo];
            [self.socketConnect readPackage:packageHeader timeout:1];
        }else{
            [self.socketConnect disconnect];
        }
        
    }
//    else{
//        [self.socketConnect disconnect];
//    }
}

- (void)tryToReplyToHTTPRequest
{
    if (![self.requestHandler hasDone]) {
        return;
    }
    
    //常见handler
    self.responseHandler = [HLHTTPResponseHandler responseHandlerWithRequestHeader:[self.requestHandler requestHeader]];
//    [self.socketConnect writePackage:[self.responseHandler writerPackage]];
    [self.socketConnect writePackage:[self.responseHandler writerPackageForHeaderInfo]];
    HLPackageWriter * body = [self.responseHandler writerPackageBody];
    if (body) {
        [self.socketConnect writePackage:body];
    }
}



@end
