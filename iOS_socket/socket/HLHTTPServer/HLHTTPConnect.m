//
//  HLHTTPConnect.m
//  iOS_socket
//
//  Created by hailong on 2020/02/01.
//  Copyright © 2020 HL. All rights reserved.
//

#import "HLHTTPConnect.h"
#import "HLPackageRead.h"

typedef enum : NSUInteger {
    PackageTypeTest,
    PackageTypeTestTerminal,
    PackageTypeTestWrite,
} PackageType;

@interface HLHTTPConnect ()
@property (nonatomic,strong) HLSocketConnect * socketConnect;
@end


@implementation HLHTTPConnect

- (instancetype)initWith:(HLSocketConnect *)socketConnect;
{
    if (self =[super init]) {
        self.socketConnect = socketConnect;
    }
    return self;
}

- (void)connect;
{
       [self.socketConnect readPackage:[HLPackageRead packageReadWithTerminator:@"bbb"]
                    packageTag:PackageTypeTestTerminal];
          [self.socketConnect readPackage:[HLPackageRead packageReadWithFixLength:100]
                    packageTag:PackageTypeTest];
}

- (void)disconnect;
{
    
}

- (void)readPackageData:(NSData*)data packageTag:(NSInteger)tag;
{
    switch (tag) {
        case PackageTypeTest:
            NSLog(@"%@",[NSString stringWithUTF8String:[data bytes]]);
            break;
        case PackageTypeTestTerminal:
            NSLog(@"%@",[NSString stringWithUTF8String:[data bytes]]);
            [self responseTestDataConnect:self.socketConnect];
            break;
        default:
            break;
    }
}

- (void)writeDonePackageTag:(NSInteger)tag;
{
    
}

#pragma mark -
#pragma mark -
- (void) responseTestDataConnect:(HLSocketConnect *)connect;
{
    NSData * data = [@"<html><body>H1hahah</body></html>" dataUsingEncoding:NSUTF8StringEncoding];
    HLPackageWriter * package = [HLPackageWriter packageWithData:data tag:PackageTypeTestWrite];
    [connect writePackage:package packageTag:PackageTypeTestWrite];
}
@end
