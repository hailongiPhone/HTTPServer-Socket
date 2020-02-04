//
//  HLHTTPHeader.h
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>




NS_ASSUME_NONNULL_BEGIN

#define kHeaderKeyContentLength     @"Content-Length"
#define kHeaderKeyHost              @"Host"
#define kHeaderKeyConnection        @"Connection"
#define kHeaderKeyContentType       @"Content-Type"
#define kHeaderKeyRange             @"Range"
#define kHeaderKeyBoundary          @"boundary"


@interface HLHeaderLine : NSObject
@property(nonatomic,strong)NSString * key;
@property(nonatomic,strong)NSString * orignalValue;
@property(nonatomic,strong)NSString * value;
@property(nonatomic,strong)NSDictionary * parameters;

+ (instancetype)lineWithKey:(NSString *)key
                      value:(NSString *)value
                 parameters:(NSDictionary *)parameters;
@end

@interface HLHeaderLine (Parser)
// lineKey: lineValue
+ (NSArray *)itemsFromLineString:(NSString *)linestring separator:(NSString *)separator;

// lineKey: lineValue
+ (HLHeaderLine*)headerLineFromLineString:(NSString *)linestring;
//默认";"作为分隔符，
// lineKey: lineValue ; 参数key=参数value；参数key1=参数value1;
+ (HLHeaderLine*)headerLineWithParametersFromLineString:(NSString *)linestring;
@end


@interface HLHTTPHeaderRequest : NSObject


@property(nonatomic, strong) NSString *method;
@property(nonatomic, strong) NSString *path;

@property(nonatomic, strong) NSString *protocol;
@property(nonatomic, strong) NSString *version;

@property(nonatomic, readonly) NSString *host;
@property(nonatomic, readonly) u_int64_t contentLength;

@property(nonatomic, readonly) NSString *boundary;
@property(nonatomic, readonly) NSString *fileName;

@property(nonatomic, readonly) BOOL hasBody;
@property(nonatomic, readonly) BOOL hasRangeHead;

@property(nonatomic, assign) BOOL hasParseDone;



@property(nonatomic, strong) NSMutableDictionary *lineMap;
- (HLHeaderLine *)lineItemForKey:(NSString *)key;
- (NSString *)valueForKey:(NSString *)key;
- (NSDictionary *)parametersForKey:(NSString *)key;


//Body中的数据访问--有5中形式 -- 暂时都在内存中，写文件似乎要合理些
@property(nonatomic, readonly) NSData *bodyRawData;

//没有处理嵌套
@property(nonatomic, readonly) NSArray<NSData *> *bodyMultipart;
//暂时不处理
@property(nonatomic, readonly) NSDictionary *bodyQueryString;
@property(nonatomic, readonly) NSString *bodyJSONString;
@property(nonatomic, readonly) NSString *bodyXMLString;

@end

@interface HLHTTPHeaderResponse : NSObject

@property(nonatomic, strong) NSString *protocol;
@property(nonatomic, strong) NSString *version;

@property(nonatomic, assign) NSInteger stateCode;
@property(nonatomic, strong) NSString *stateDesc;
@property(nonatomic, assign) u_int64_t contentLength;

@property(nonatomic, strong) NSMutableDictionary *lineMap;
- (void)setValue:(NSString *)value ForKey:(NSString *)key;
- (NSData *)achiveData;
@end

NS_ASSUME_NONNULL_END


#import "HLHeaderParser.h"
