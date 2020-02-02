//
//  HLHTTPHeader.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLHTTPHeader : NSObject
@property(nonatomic, strong) NSString *protocol;
@property(nonatomic, strong) NSString *version;
@property(nonatomic, strong) NSDictionary *headDic;
@end

@interface HLHTTPHeaderRequest : HLHTTPHeader
@property(nonatomic, strong) NSString *method;
@property(nonatomic, strong) NSString *path;
@property(nonatomic, strong) NSString *host;
@end

@interface HLHTTPHeaderResponse : HLHTTPHeader
@property(nonatomic, strong) NSInteger stateCode;
@property(nonatomic, strong) NSString *stateDesc;
@end

NS_ASSUME_NONNULL_END
