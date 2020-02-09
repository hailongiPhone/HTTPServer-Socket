//
//  HLBody.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLBodyPart.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HLBodyType) {
    HLBodyTypeQueryString,
    HLBodyTypeFile,
    HLBodyTypeJSON,
    HLBodyTypeXML,
};

#define kBodyContentQueryString     @"application/x-www-form-urlencoded"
#define kBodyContentMultipart       @"multipart/form-data"
#define kBodyContentJSON            @"application/json"
#define kBodyContentXML             @"text/xml"

@class HLBodyHeader;

@interface HLBody : NSObject
@property (nonatomic,strong) HLBodyHeader * header;
@property (nonatomic,strong) NSMutableArray<HLBodyPart *> * bodyPart;

- (void)addBodyPart:(HLBodyPart *)part;

+ (instancetype) bodyWithRequestHeaderContentType:(NSString *)contentType
                                       parameters:(NSDictionary *)parameters;

@end

@interface HLBodyHeader : NSObject
@property (nonatomic,readwrite) HLBodyType bodytype;
@property (nonatomic,strong) NSDictionary * parameters;
@property (nonatomic,strong) NSString * charset;


//header中原始的contentType字段需要解析 --
//参数中的contentType，parameter是解析过后的结果
+ (instancetype) bodyHeaderWithRequestHeaderContentType:(NSString *)contentType
                                             parameters:(NSDictionary *)parameters;
- (void)updateBodyTypeWith:(NSString *)contentType
                parameters:(NSDictionary *)parameters;
@end

NS_ASSUME_NONNULL_END
