//
//  HLHTTPHeader.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPHeader.h"

@interface HLHeaderLine ()
@property(nonatomic,assign)BOOL hasParse;
@end

@interface HLHeaderLine (Parser)
// lineKey: lineValue
- (void)parserKeyValueFromLineString:(NSString *)linestring;
//默认";"作为分隔符，
// lineKey: lineValue ; 参数key=参数value；参数key1=参数value1;
- (void)parserParametersFromValueString:(NSString *)valueString;
@end

@implementation HLHeaderLine

+ (instancetype)lineWithLineString:(NSString * )lineString;
{
    HLHeaderLine * tmp = [HLHeaderLine new];
    [tmp parserKeyValueFromLineString:lineString];
    return tmp;
}

+ (instancetype)lineWithKey:(NSString *)key
                      value:(NSString *)value
                 parameters:(NSDictionary *)parameters;
{
    HLHeaderLine * tmp = [HLHeaderLine new];
    tmp.key = key;
    tmp.value = value;
    tmp.parameters = parameters;
    return tmp;
}

- (NSDictionary *)parameters;
{
    if (!self.hasParse) {
        [self parserParametersFromValueString:self.orignalValue];
    }
    return self->_parameters;
}

@end

@implementation HLHeaderLine (Parser)

- (void)parserKeyValueFromLineString:(NSString *)linestring
{
    NSArray *headItems =  [linestring componentsSeparatedByString:@": "];
    if(headItems.count != 2) {
        return;
    }
    self.key = [headItems[0] stringByRemovingPercentEncoding];
    self.orignalValue = [headItems[1] stringByRemovingPercentEncoding];
    self.value = [headItems[1] stringByRemovingPercentEncoding];
}

//默认";"作为分隔符，
// lineKey: lineValue ; 参数key=参数value；参数key1=参数value1;
- (void)parserParametersFromValueString:(NSString *)valueString;
{
    NSArray * items;
    if (valueString) {
        items = [valueString componentsSeparatedByString:@"; "];
    }
    if (items) {
        self.value = [items firstObject];
        
        NSInteger count = [items count];
        
        NSMutableDictionary * parameters = [[NSMutableDictionary alloc] initWithCapacity:count];
        for (NSInteger i = 1; i < count; i++) {
            NSString * param = [items objectAtIndex:i];
            NSArray * array = [param componentsSeparatedByString:@"="];
            if ([array count] == 2) {
                [parameters setValue:array[1] forKey:array[0]];
                break;
            }
        }
        
        self.parameters = parameters;
    }
    
    self.hasParse = YES;
}

@end


@implementation HLHTTPHeaderRequest
- (instancetype)init;
{
    if (self = [super init]) {
        self.lineMap = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}

- (NSString *)host;
{
    return [self valueForKey:kHeaderKeyHost];
}

- (u_int64_t)contentLength;
{
    u_int64_t l = 0;
    NSString * length = [self valueForKey:kHeaderKeyContentLength];;
    if (length) {
        l = strtoull([length UTF8String], NULL, 0);
    }
    return l;
}

- (NSString *)boundary;
{
    NSDictionary * parameters = [self parametersForKey:kHeaderKeyContentType];
    return [parameters valueForKey:kHeaderKeyBoundary];
}

- (NSString *)fileName;
{
    NSString * fromPath = [self.path lastPathComponent];
    fromPath = [fromPath stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([fromPath length] < 1) {
        fromPath = @"1";
    }
    return fromPath;
}

- (BOOL)hasBody;
{
    return self.contentLength >0;
}

- (BOOL)keepAlive;
{
    BOOL result = NO;
    if ([self.version floatValue] < 1) {
        
    }else if([self.version floatValue] < 1.01){
        NSString * connection = [self valueForKey:kHeaderKeyConnection];
        if ([connection isEqualToString:kHeaderKeyConnectionKeepAlive]) {
            result = YES;
        }
    }else{
        NSString * connection = [self valueForKey:kHeaderKeyConnection];
        if (connection && [connection isEqualToString:kHeaderKeyConnectionClose] ) {
            result = NO;
        }else{
            result = YES;
        }
    }
    
    return result;
}

- (BOOL)hasRangeHead;
{
    NSString * value = [self valueForKey:kHeaderKeyRange];
    return [value hasPrefix:@"bytes="];
}

#pragma mark -



- (HLHeaderLine *)lineItemForKey:(NSString *)key;
{
    if (!self.lineMap) {
        return nil;
    }
    return [self.lineMap valueForKey:key];
}

- (NSString *)valueForKey:(NSString *)key;
{
    HLHeaderLine * lineItem = [self lineItemForKey:key];
    if (!lineItem) {
        return nil;
    }
    return lineItem.value;
}

- (NSDictionary *)parametersForKey:(NSString *)key;
{
    HLHeaderLine * lineItem = [self lineItemForKey:key];
    if (!lineItem) {
        return nil;
    }
    return [lineItem parameters];
}


@end

@implementation HLHTTPHeaderResponse

- (instancetype)init;
{
    if (self = [super init]) {
        self.lineMap = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}


- (NSData *)achiveData{
    NSMutableString *headStr = @"".mutableCopy;
    [headStr appendFormat:@"%@/%@ %zd %@\r\n",self.protocol,self.version, self.stateCode, self.stateDesc];
    [self.lineMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [headStr appendFormat:@"%@:%@\r\n",key,obj];
    }];
    [headStr appendString:@"\r\n"];
    return [headStr dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)setValue:(NSString *)value ForKey:(NSString *)key;
{
    [self.lineMap setObject:value forKey:key];
}


+ (HLHTTPHeaderResponse *)headerForRequestHeader:(HLHTTPHeaderRequest *)requestHeader;
{
    NSDate *date = [NSDate date];
    NSString *dataStr = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle];
    NSDictionary *dic = @{
                          @"Date"   : dataStr,
                          @"Server" : @"HLHTTPServer",
                          @"Accept-Ranges": @"bytes"
                          };
    
    HLHTTPHeaderResponse * header = [HLHTTPHeaderResponse new];
    header.lineMap = dic.mutableCopy;
    header.protocol = requestHeader.protocol;
    header.version = requestHeader.version;
    header.stateCode = [requestHeader hasRangeHead] ? 206 : 200;
    header.stateDesc = @"OK";
    
    return header;
}
@end
