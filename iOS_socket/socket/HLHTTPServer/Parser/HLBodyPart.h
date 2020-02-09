//
//  HLBodyPart.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@class HLBodyPartHeader;
@interface HLBodyPart : NSObject
@property(nonatomic,strong) HLBodyPartHeader * header;
@property(nonatomic,strong) NSData * data;

- (void)updateHeaderWithData:(NSData *)data;
- (void)updateBodyPartData:(NSData *)data;
@end


@interface HLBodyPartHeader : NSObject
@property(nonatomic,readonly) NSString * disposition;
@property(nonatomic,readonly) NSString * type;
@property(nonatomic,readonly) NSString * transferEncoding;
@property(nonatomic,readonly) NSString * fileName;

+ (instancetype)headerWithData:(NSData *)data;
+ (instancetype)headerWithDictionary:(NSDictionary *)dictioanry;
@end

NS_ASSUME_NONNULL_END
