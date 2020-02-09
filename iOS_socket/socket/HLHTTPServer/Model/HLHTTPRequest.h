//
//  HLHTTPRequest.h
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPHeader.h"
#import "HLBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPRequest : NSObject
@property (nonatomic,strong) HLHTTPHeaderRequest * header;
@property (nonatomic,strong) HLBody * body;

-(BOOL) keepAlive;
@end

NS_ASSUME_NONNULL_END
