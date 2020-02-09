//
//  HLMultipartBodyParser.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPHeader.h"
#import "HLBody.h"
NS_ASSUME_NONNULL_BEGIN


@interface HLMultipartBodyParser : NSObject

@property (nonatomic,strong)HLBody * requestBody;


+(instancetype)parseWithHeader:(HLHTTPHeaderRequest *)header;
-(void)addData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
