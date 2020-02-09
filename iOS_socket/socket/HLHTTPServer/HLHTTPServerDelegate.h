//
//  HLHTTPServerDelegate.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//
#import "HLHTTPHeader.h"
#import "HLHTTPRequest.h"
#import "HLHTTPResponse.h"

@protocol HLHTTPRequestDelegate <NSObject>
@optional
-(HLHTTPResponse*) responseForRequest:(HLHTTPRequest*)request;

@end

@protocol HLHTTPResponseDelegate <NSObject>

@optional
-(void) httpserverResponseDone:(HLHTTPResponse *)response;
@end

