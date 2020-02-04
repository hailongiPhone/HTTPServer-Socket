//
//  HLBody.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLBody.h"

@implementation HLBody

@end

@implementation HLBodyHeader

+ (instancetype) bodyHeaderWithRequestHeaderContentType:(NSString *)contentType;
{
    HLBodyHeader * tmp = [HLBodyHeader new];
    [tmp loadFromCOntentType:contentType];
    return tmp;
}

- (void)loadFromCOntentType:(NSString *)contentType;
{
    
}

@end
