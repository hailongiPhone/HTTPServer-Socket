//
//  HLHTTPRequest.m
//  iOS_socket
//
//  Created by hailong on 2020/01/20.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPRequest.h"

@implementation HLHTTPRequest

-(BOOL) keepAlive;
{
    return [self.header keepAlive];
}
@end
