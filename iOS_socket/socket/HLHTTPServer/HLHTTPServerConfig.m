//
//  HLHTTPServerConfig.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPServerConfig.h"

@implementation HLHTTPServerConfig
+(instancetype)defaultConfig;
{
    HLHTTPServerConfig * tmp = [HLHTTPServerConfig new];
    tmp.port = 55667;
    tmp.rootDirectory = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
             inDomain:NSUserDomainMask
    appropriateForURL:nil
               create:YES
                error:nil] path];
    
    return tmp;
}
@end
