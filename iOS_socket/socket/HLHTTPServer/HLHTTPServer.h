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
#import "HLHTTPServerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLHTTPServerProtocol <NSObject>

-(instancetype)initWithPort:(NSInteger)port;
-(void)setDocumentRoot:(NSString*)path;

@end


@interface HLHTTPServer : NSObject <HLHTTPServerProtocol>
@property (nonatomic,readonly)NSInteger port;
@property (nonatomic,weak)id<HLHTTPRequestDelegate> delegate;

-(instancetype)initWithPort:(NSInteger)port;
//文件路径
-(void)setDocumentRoot:(NSString*)path;
@end

NS_ASSUME_NONNULL_END
