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
@property(nonatomic, strong) NSString *method;
@property(nonatomic, strong) NSMutableDictionary *headDic;
@end

@interface HLHTTPHeaderRequest : HLHTTPHeader

@property(nonatomic, strong) NSString *path;
@property(nonatomic, strong) NSString *host;
@property(nonatomic, assign) u_int64_t contentLength;
@property(nonatomic, strong) NSDictionary *queryString;
- (BOOL)hasBody;
- (NSString *)fileName;
- (BOOL)hasRangeHead;
@end

@interface HLHTTPHeaderResponse : HLHTTPHeader
@property(nonatomic, assign) NSInteger stateCode;
@property(nonatomic, strong) NSString *stateDesc;
@property(nonatomic, assign) u_int64_t contentLength;

- (NSData *)dataOfHeader;
@end

NS_ASSUME_NONNULL_END
