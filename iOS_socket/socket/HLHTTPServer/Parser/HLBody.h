//
//  HLBody.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HLBodyType) {
    HLBodyTypeQueryString,
    HLBodyTypeFile,
    HLBodyTypeJSON,
    HLBodyTypeXML,
};

@interface HLBody : NSObject

@end

@interface HLBodyHeader : NSObject
@property (nonatomic,readwrite) HLBodyType bodytype;
@property (nonatomic,strong) NSString * boundary;
@property (nonatomic,strong) NSString * charset;

+ (instancetype) bodyHeaderWithRequestHeaderContentType:(NSString *)contentType;

@end

NS_ASSUME_NONNULL_END
