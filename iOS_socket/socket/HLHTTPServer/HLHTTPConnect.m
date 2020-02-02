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



@interface HLHTTPConnect ()
@property (nonatomic,strong) HLSocketConnect * socketConnect;
@property (nonatomic,strong) HLHTTPRequestHandler * requestHandler;
@end


@implementation HLHTTPConnect

- (instancetype)initWith:(HLSocketConnect *)socketConnect;
{
    if (self =[super init]) {
        self.socketConnect = socketConnect;
    }
    return self;
}

- (void)connect;
{
    self.requestHandler = [HLHTTPRequestHandler new];
    
    HLPackageRead * packageHeader = [self.requestHandler readPackageForHeaderInfo];
    [self.socketConnect readPackage:packageHeader];
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
            NSLog(@"Header == %@",[NSString stringWithUTF8String:[data bytes]]);
            [self.requestHandler onReciveHeadData:data];
            HLPackageRead * packageBody = [self.requestHandler readPackageBody];
            if (packageBody) {
                [self.socketConnect readPackage:packageBody];
            }else{
                [self tryToReplyToHTTPRequest];
            }
        }
            break;
        case HLRequestPackageTagBody:
        {
            NSLog(@"Body == %@",[NSString stringWithUTF8String:[data bytes]]);
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
    
}

- (void)tryToReplyToHTTPRequest
{
    if (![self.requestHandler hasDone]) {
        return;
    }
    
    //常见handler
//    self.responseHandeler = [ZGHTTPResponseHandeler initWithRequestHead:_requestHandler.requestHead
//                                                               delegate:_config.responseDelegate
//                                                                rootDir:_config.rootDirectory];
//
//    [_socket writeData:[_responseHandeler readAllHeadData] withTimeout:kZGHTTPConnectTimeout tag:kZGHTTPResponseHeadTag];
}

#pragma mark -
#pragma mark -
- (void) responseTestDataConnect:(HLSocketConnect *)connect;
{
    NSData * data = [@"<html><body>H1hahah</body></html>" dataUsingEncoding:NSUTF8StringEncoding];
    HLPackageWriter * package = [HLPackageWriter packageWithData:data tag:1];
    [connect writePackage:package];
}
@end
