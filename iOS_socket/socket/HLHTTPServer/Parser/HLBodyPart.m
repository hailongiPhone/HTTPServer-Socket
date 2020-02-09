//
//  HLBodyPart.m
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLBodyPart.h"

@implementation HLBodyPart
- (void)updateHeaderWithData:(NSData *)data;
{
    HLBodyPartHeader * header = [HLBodyPartHeader headerWithData:data];
    self.header = header;
}

- (void)updateBodyPartData:(NSData *)data;
{
    self.data = data;

}

@end


@interface HLBodyPartHeader ()
@property(nonatomic,strong) NSDictionary * dictioanry;
@end

@implementation HLBodyPartHeader
+ (instancetype)headerWithData:(NSData *)data;
{
    HLBodyPartHeader * tmp = [HLBodyPartHeader new];
    [tmp updateFrom:data];
    return tmp;
}

+ (instancetype)headerWithDictionary:(NSDictionary *)dictioanry;
{
    HLBodyPartHeader * tmp = [HLBodyPartHeader new];
    tmp.dictioanry = dictioanry;
    return tmp;
}

- (void)updateFrom:(NSData *)data;
{
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray * lines = [str componentsSeparatedByString:@"\r\n"];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString * aline in lines) {
        NSArray * mainKey = [aline componentsSeparatedByString:@": "];
        if (mainKey.count == 2) {
            
            NSString * value = mainKey[1];
            [dict setValue:value forKey:mainKey[0]];
            
            NSArray * valueKeyValue = [value componentsSeparatedByString:@"; "];
            for (NSString * str in valueKeyValue) {
                NSArray * sub = [str componentsSeparatedByString:@"="];
                if ([sub count] == 2) {
                    [dict setValue:sub[1] forKey:sub[0]];
                }else{
                    [dict setValue:str forKey:mainKey[0]];
                }
            }
        }
    
    }
    
    self.dictioanry = dict;
}

- (NSString *) disposition;
{
    return [self.dictioanry valueForKey:@"Content-Disposition"];
}
- (NSString *) type;
{
    return [self.dictioanry valueForKey:@"Content-Type"];
}
- (NSString *) transferEncoding;
{
    return [self.dictioanry valueForKey:@"Transfer-Encoding"];
}

- (NSString *) fileName;
{
    NSString * string = [self.dictioanry valueForKey:@"filename"];
//    escapedString = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    return  [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}

@end
