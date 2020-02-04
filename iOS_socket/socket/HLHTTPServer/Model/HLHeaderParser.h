//
//  HLHeaderParser.h
//  iOS_socket
//
//  Created by hailong on 2020/02/03.
//  Copyright © 2020 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLHTTPHeader.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * HLHTTPHeader的解析工作，可以手动完成，也可以使用CFNetwork提供的底层库
 * HLHTTPHeader的数据获取，有两种方式，
 *      1：整块获取--由于Header的结束标志很明显可以用/r/n/r/n，可以一次性获取，
 *                         优点：是代码易懂，
 *                         缺点：但是解析的时候还要分行，比安行处理慢，
 *                              内存占用要多些
 *      2：一行一行获取，每行的结束标志很明确 /r/n
 *                     直到读取、/r/n/r/n表明header解析完成
 */
/*
GET /minion.png HTTP/1.1 // 包含了请求方法、请求资源路径、HTTP协议版本
Host: 120.25.226.186:32812 // 客户端想访问的服务器主机地址
User-Agent: Mozilla/5.0 // 客户端的类型，客户端的软件环境
Accept: text/html // 客户端所能接收的数据类型
Accept-Language: zh-cn // 客户端的语言环境
Accept-Encoding: gzip // 客户端支持的数据压缩格式
*/
//

@interface HLHTTPHeaderRequest (Parser)
//所有数据获取
- (void)parseFromAllData:(NSData *)data;
- (void)parseAddLineData:(NSData *)linedata;
- (BOOL) loadFromFirstLineItem:(NSArray *)items;
@end

@interface HLHTTPHeaderRequest (ParserCFNetwork)

@end

NS_ASSUME_NONNULL_END
