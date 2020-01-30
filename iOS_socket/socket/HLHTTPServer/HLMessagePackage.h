//
//  HLMessagePackage.h
//  iOS_socket
//
//  Created by hailong on 2020/01/21.
//  Copyright © 2020 HL. All rights reserved.
//


/**
 *  Socket的写策略，如果不确定要读什么（没有指定的报文读取策略），就放到preBuffer中缓存，
 *    如果有确定的报文读取策略，就直接从socket读取到对应的报文读取策略中
 *
 *  HLMessagePackage 用于读取一个有效的报文
 *      指定报文读写策略，如定长读取，特殊字符串读取
 *         报文数据
 *
 *  报文读取流程
 *       （因为从preBuffer中读取，报文还要多一次数据拷贝，所以尽可能直接从socket中读取）
 *       从缓存Prebuffer中读取，如果为空，从socket中直接读取
*/

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface HLMessagePackage : NSObject

@end

NS_ASSUME_NONNULL_END
