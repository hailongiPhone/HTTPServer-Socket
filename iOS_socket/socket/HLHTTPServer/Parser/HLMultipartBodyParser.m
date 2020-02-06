//
//  HLMultipartBodyParser.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLMultipartBodyParser.h"
#import "HLBody.h"
#import "HLBodyPart.h"

@interface HLMultipartBodyParser ()
@property (nonatomic,strong)NSData * data;
@property (nonatomic,strong)HLHTTPHeaderRequest * header;
@end
@implementation HLMultipartBodyParser
+(instancetype)parseWithHeader:(HLHTTPHeaderRequest *)header;
{
    HLMultipartBodyParser * tmp = [HLMultipartBodyParser new];
    tmp.header = header;
    [tmp setupBodyData:header];
    return tmp;
}

- (void) setupBodyData:(HLHTTPHeaderRequest *)header;
{
    
}

-(void)addData:(NSData *)data;
{
    
}
@end
