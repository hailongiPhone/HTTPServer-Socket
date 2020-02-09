//
//  HLBody.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLBody.h"

@implementation HLBody

+ (instancetype) bodyWithRequestHeaderContentType:(NSString *)contentType
                                       parameters:(NSDictionary *)parameters;
{
    HLBody * tmp = [HLBody new];
    
    [tmp updateBodyTypeWith:contentType parameters:parameters] ;
    return tmp;
}

- (void)updateBodyTypeWith:(NSString *)contentType
                parameters:(NSDictionary *)parameters;
{
    self.header = [HLBodyHeader bodyHeaderWithRequestHeaderContentType:contentType
                                                            parameters:parameters];
    
}


- (void)addBodyPart:(HLBodyPart *)part;
{
    if (!self.bodyPart) {
        self.bodyPart = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [self.bodyPart addObject:part];
}
@end

@implementation HLBodyHeader

//header中原始的contentType字段需要解析
+ (instancetype) bodyHeaderWithRequestHeaderContentType:(NSString *)contentType
                                             parameters:(NSDictionary *)parameters;
{
    HLBodyHeader * tmp = [HLBodyHeader new];
    [tmp updateBodyTypeWith:contentType parameters:parameters] ;
    return tmp;
}


- (void)updateBodyTypeWith:(NSString *)contentType
                parameters:(NSDictionary *)parameters;
{
    self.bodytype = [self bodyTypeFromString:contentType];
    self.charset = [parameters valueForKey:@"charset"];
    self.parameters = parameters;
}

- (HLBodyType)bodyTypeFromString:(NSString *)contentType;
{
    HLBodyType type = HLBodyTypeFile;
    if ([contentType isEqualToString:kBodyContentMultipart]) {
        
    }else if([contentType isEqualToString:kBodyContentJSON]) {
        type = HLBodyTypeJSON;
    }else if([contentType isEqualToString:kBodyContentXML]) {
        type = HLBodyTypeXML;
    }else if([contentType isEqualToString:kBodyContentQueryString]) {
        type = HLBodyTypeQueryString;
    }
    
    return type;
}
@end
