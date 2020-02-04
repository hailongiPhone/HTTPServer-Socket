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
@end


@interface HLBodyPartHeader : NSObject
@property(nonatomic,strong) NSString * disposition;
@property(nonatomic,strong) NSString * type;
@property(nonatomic,strong) NSString * transferEncoding;
@property(nonatomic,strong) NSString * fileName;
@end

NS_ASSUME_NONNULL_END
