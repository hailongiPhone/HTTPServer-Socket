//
//  HLHeaderParser.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHeaderParser.h"


@implementation HLHTTPHeaderRequest (Parser)
- (void)parseFromAllData:(NSData *)data;
{
    //先分行
    NSString *headStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *lines = [headStr componentsSeparatedByString:@"\r\n"];
    
   
    __block BOOL done = YES;
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if(line.length == 0) return ;
        if(idx == 0){
             //第一行
            NSArray * first = [line componentsSeparatedByString:@" "];
            if(![self loadFromFirstLineItem:first]){
                NSLog(@"ERROR!!! header first Line value error.");
                *stop = YES;
                done = NO;
                return;
            }
        }else{
            HLHeaderLine * lineItem = [HLHeaderLine lineWithLineString:line];
            [self.lineMap setValue:lineItem forKey:lineItem.key];
        }
    }];
    
    
    self.hasParseDone = done;
}

- (BOOL) loadFromFirstLineItem:(NSArray *)items;
{
    if (!items || [items count]<3) {
        return NO;
    }
    
    self.method = items[0];
    self.path = items[1];
    
    NSString * protocalVersion = items[2];
    NSArray * components = [protocalVersion componentsSeparatedByString:@"/"];
    if(components.count != 2) {
        return NO;
    }
    
    self.protocol = components[0];
    self.version = components[1];
    
    return YES;
}

- (void)parseAddLineData:(NSData *)linedata;
{
    NSString *lineString = [[NSString alloc] initWithData:linedata encoding:NSUTF8StringEncoding];
    if ([lineString isEqualToString:@"\r\n\r\n"]) {
        self.hasParseDone = YES;
        return;
    }
    
    if (!self.method) {
        NSArray * items = [lineString componentsSeparatedByString:@" "];
        [self loadFromFirstLineItem:items];
    }else{
        HLHeaderLine * lineItem = [HLHeaderLine lineWithLineString:lineString];
        [self.lineMap setValue:lineItem forKey:lineItem.key];
    }
}
@end


@implementation HLHTTPHeaderRequest (ParserCFNetwork)

@end





