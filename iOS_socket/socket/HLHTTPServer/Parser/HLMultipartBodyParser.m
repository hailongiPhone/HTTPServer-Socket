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

#import "HLSocketReader.h"
#import "HLPackageRead.h"
#import "HLBodyPart.h"

#import <UIKit/UIKit.h>

@interface HLMultipartBodyParser ()

@property (nonatomic,strong)NSMutableData * data;
@property (nonatomic,assign)NSUInteger offset;


@property (nonatomic,strong)HLBodyPart * parsePart;
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
    NSString * contentType = [header valueForKey:kHeaderKeyContentType];
    NSDictionary * par = [header parametersForKey:kHeaderKeyContentType];
    
    self.requestBody = [HLBody bodyWithRequestHeaderContentType:contentType
                                              parameters:par];
    
    self.data = [NSMutableData data];
    
}

-(void)addData:(NSData *)data;
{
    [self.data appendData:data];
    
    NSUInteger length = [self.data length] - self.offset;
    NSData * currentData = [NSData dataWithBytesNoCopy:(int8_t *)[self.data bytes] + self.offset
                                                length:length
                                          freeWhenDone:NO];
    
    
    [self parseBodyPartData:currentData];
}

//解析body和Socket的报文解析类似
//mutapart data 一次性传入的是一个part的读取相关
// 有一个开始标记 然后是header行、行 + 空行 + 数据 + boundary --
- (void)parseBodyPartData:(NSData*)data;
{

    HLBodyPart * bodyPart = nil;
    while ((bodyPart = [self readBodyPartFromBodydata:data])) {
        [self.requestBody addBodyPart:bodyPart];
    }
    
}


#define kBodyPartReadTagStart 1
#define kBodyPartReadTagHeader 2
#define kBodyPartReadTagEnd 3
- (HLBodyPart *)readBodyPartFromBodydata:(NSData *)bodyData;
{
    
    
    NSMutableArray * readers = [[NSMutableArray alloc] initWithCapacity:10];
    NSString * boundary = [self boundary];
    NSInteger boundaryLength = [boundary length];
    
    //结束处理，最好的结束处理是标志boundary+"--\r\n"
    if ([bodyData length] - self.offset <= boundaryLength + 4) {
        NSData * data = [NSData dataWithBytes:[bodyData bytes] + self.offset length:[bodyData length] - self.offset];
        NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str isEqualToString:[NSString stringWithFormat:@"%@--\r\n",boundary]]) {
            NSLog(@"正常解析完成");
        }
        return nil;
    }
    
    //bodyPart 的开始标志
    NSString *boundaryline = [NSString stringWithFormat:@"%@\r\n",boundary];
    [readers addObject:[HLPackageRead packageReadWithTerminator:boundaryline tag:kBodyPartReadTagStart]];
    
    //bodypart header 标志
    NSString *headerEndline = @"\r\n\r\n";
    [readers addObject:[HLPackageRead packageReadWithTerminator:headerEndline tag:kBodyPartReadTagHeader]];
    //bodypart 的结尾标志
    [readers addObject:[HLPackageRead packageReadWithTerminator:boundary tag:kBodyPartReadTagEnd]];
    
    //字节读取位置
//    NSUInteger offset= self.offset;
    
    HLBodyPart* part = [HLBodyPart new];
    
    while ([readers count] > 0){
        HLPackageRead * package = [readers firstObject];
        uint8_t * readBuffer = (uint8_t *)[bodyData bytes] + self.offset;
        NSUInteger availableLength = [bodyData length] - self.offset;
        
        NSUInteger bytesToCopy = [package readLengthForData:readBuffer availableLength:availableLength];
        
        [package ensureCapacityForAdditionalDataOfLength:bytesToCopy];
        
        //数据拷贝
        uint8_t *buffer = [package writeBuffer];
        memcpy(buffer,readBuffer, bytesToCopy);
        
        //更新数据读取位置
        self.offset +=bytesToCopy;
        //结束boundary标志也是下一个的开始，如果为了提速，可以不会退，用标志位标识
        if(package.tag == kBodyPartReadTagEnd){
            self.offset -= boundaryLength;
        }
        
        [package didWrite:bytesToCopy];
        
        
        if ([package hasDone]) {
            [readers removeObject:package];
        }
        
        if (package.tag == kBodyPartReadTagStart) {
            continue;
        }
        uint8_t * readBuffera = [package readBuffer];
        NSData * data = [NSData dataWithBytes:readBuffera length:bytesToCopy];
        
        if (package.tag == kBodyPartReadTagHeader) {
            NSString * Str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [part updateHeaderWithData:data];
        }else{
            UIImage * image = [UIImage imageWithData:data];
            [part updateBodyPartData:data];
        }
    }
    
    return part;
}

//- (NSUInteger)CRLFEndPosition:(uint8_t * )buffer length:(NSUInteger)length;
//{
//
//    NSUInteger offset = 0;
//    //\r\n  0x0A0D
//    while ( *(uint16_t*)(buffer + offset) != 0x0A0D ) {
//        offset++;
//        if( offset >= length ) {
//            // no endl found within current data
//            return -1;
//        }
//    }
//
//    offset += 2;
//    return offset;
//}
//
//- (NSUInteger)boundaryEndPosition;
//{
//    return 0;
//}
//
//- (NSUInteger)boundaryStartPosition;
//{
//    return 0;
//}



- (NSString *)boundary;
{
    return [[[self header] parametersForKey:kHeaderKeyContentType] valueForKey:@"boundary"];
}
@end
