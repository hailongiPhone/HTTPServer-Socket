//
//  HLHTTPServer.h
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPRequest.h"
#import "HLHTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLHTTPServerProtocol <NSObject>

-(instancetype)initWithPort:(NSInteger)port;

@end

@protocol HLHTTPServerDelegate <NSObject>

-(void) httpserverOnRequest:(HLHTTPRequest*)request fillResponse:(HLHTTPResponse*) response;

@end

@interface HLHTTPServer : NSObject <HLHTTPServerProtocol>
@property (nonatomic,readonly)NSInteger port;

-(instancetype)initWithPort:(NSInteger)port;
@end

NS_ASSUME_NONNULL_END
