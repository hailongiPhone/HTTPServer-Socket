//
//  ViewController.m
//  iOS_socket
//
//  Created by hailong on 2020/01/13.
//  Copyright © 2020 HL. All rights reserved.
//

#import "ViewController.h"
#import "IPAddress.h"

#import "BaseSocket.h"

#import "HLHTTPServer.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

@interface ViewController () <HLHTTPRequestDelegate>
@property(nonatomic,strong) BaseSocket * bs;
@property(nonatomic,strong) BaseSocket * bc;

@property (nonatomic,strong) HLHTTPServer *httpServer;
@property (weak, nonatomic) IBOutlet UITextView *ipText;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) NSString * path;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.bs = [BaseSocket new];
        //        [self.bs setupServerLocalIPCDgram];
        
    });
    //
    //    [self listIP];
    
    //    [[self class] startCFStreamThreadIfNeeded];
    self.path = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:YES
                                                           error:nil] path];
    NSInteger port = 55667;
    self.httpServer = [HLHTTPServer serverWithConfig:^(HLHTTPServerConfig * _Nonnull config) {
        config.requestDelegate = self;
        config.port = port;
        config.rootDirectory = self.path;
    }];
    
    NSString * ipstr = [[self class] getIPAddress];
    NSLog(@"ipstr = %@",ipstr);
    
    [self.ipText setText:[NSString stringWithFormat:@"%@:%ld",ipstr,(long)port]];
}

- (IBAction)onTapButton:(id)sender {
    
    [self.bs setupClinetTCP];
    //    [self getRequestWithCFNetwork];
    //    [[self class] stopCFStreamThreadIfNeeded];
    
    //    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"da bao" message:@"Aa" preferredStyle:UIAlertControllerStyleAlert];
    //    [self presentViewController:alert animated:YES completion:^{
    //        
    //    }];
}

- (void) listIP;
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    int i;
    //    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;            // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        NSLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
    }
}




#pragma mark - Request

//#define SERVER_PORT 55667
//#define SERVER_ADD  "127.0.0.1"
- (void)getRequestWithCFNetwork
{
    //创建请求
    CFStringRef url = CFSTR("http://127.0.0.1:55667");
    CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
    
    CFStringRef requestMethod = CFSTR("GET");
    CFHTTPMessageRef myRequest =
    CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL,
                               kCFHTTPVersion1_1);
    // 设置header
    CFHTTPMessageSetHeaderFieldValue(myRequest, CFSTR("Content-Type"), CFSTR("application/x-www-form-urlencoded; charset=utf-8"));
    
    //创建流并开启
    CFReadStreamRef requestStream = CFReadStreamCreateForHTTPRequest(NULL, myRequest);
    CFReadStreamOpen(requestStream);
    //接收响应
    NSMutableData *responseBytes = [NSMutableData data];
    CFIndex numBytesRead = 0;
    
    NSDate * lastReadDate;
    do {
        UInt8 buf[1024];
        
        BOOL hasValue = CFReadStreamHasBytesAvailable(requestStream);
        if (!hasValue) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            continue;
        }
        numBytesRead = CFReadStreamRead(requestStream, buf, sizeof(buf));
        
        if (numBytesRead > 0) {
            [responseBytes appendBytes:buf length:numBytesRead];
        }
        lastReadDate = [NSDate date];
        //    } while (!lastReadDate || [[NSDate date] timeIntervalSinceDate:lastReadDate] < 100);
    } while (numBytesRead == 0);
    
    CFHTTPMessageRef response = (CFHTTPMessageRef) CFReadStreamCopyProperty(requestStream, kCFStreamPropertyHTTPResponseHeader);
    CFHTTPMessageSetBody(response, (__bridge CFDataRef)responseBytes);
    CFReadStreamClose(requestStream);
    CFRelease(requestStream);
    CFAutorelease(response);
    
    //转换为JSON
    CFIndex statusCode;
    statusCode = CFHTTPMessageGetResponseStatusCode(response);
    CFDictionaryRef header = CFHTTPMessageCopyAllHeaderFields(response);
    CFDataRef responseDataRef = CFHTTPMessageCopyBody(response);
    NSData *responseData = (__bridge NSData *)responseDataRef;
    //    NSMutableDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    //    NSLog(@"responseBody: %@", jsonInfo);
    NSLog(@"header: %@",(__bridge NSDictionary *)header);
    NSLog(@"responseBody: %@", [NSString stringWithCString:[responseData bytes] encoding:NSUTF8StringEncoding]);
}
- (void)postRequestWithCFNetwork
{
    //创建请求
    CFStringRef url = CFSTR("http://127.0.0.1:55667");
    CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
    
    CFStringRef requestMethod = CFSTR("POST");
    CFHTTPMessageRef myRequest =
    CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL,
                               kCFHTTPVersion1_1);
    // 设置body
    NSData *dataToPost = [@"apptoken=-1" dataUsingEncoding:NSUTF8StringEncoding];
    CFHTTPMessageSetBody(myRequest, (__bridge CFDataRef) dataToPost);
    // 设置header
    CFHTTPMessageSetHeaderFieldValue(myRequest, CFSTR("Content-Type"), CFSTR("application/x-www-form-urlencoded; charset=utf-8"));
    
    //创建流并开启
    CFReadStreamRef requestStream = CFReadStreamCreateForHTTPRequest(NULL, myRequest);
    CFReadStreamOpen(requestStream);
    //接收响应
    NSMutableData *responseBytes = [NSMutableData data];
    
    CFIndex numBytesRead = 0;
    do {
        UInt8 buf[1024];
        BOOL hasValue = CFReadStreamHasBytesAvailable(requestStream);
        if (!hasValue) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            continue;
        }
        numBytesRead = CFReadStreamRead(requestStream, buf, sizeof(buf));
        
        if (numBytesRead > 0) {
            [responseBytes appendBytes:buf length:numBytesRead];
        }
    } while (numBytesRead > 0);
    
    CFHTTPMessageRef response = (CFHTTPMessageRef) CFReadStreamCopyProperty(requestStream, kCFStreamPropertyHTTPResponseHeader);
    CFHTTPMessageSetBody(response, (__bridge CFDataRef)responseBytes);
    CFReadStreamClose(requestStream);
    CFRelease(requestStream);
    CFAutorelease(response);
    
    //转换为JSON
    CFIndex statusCode;
    statusCode = CFHTTPMessageGetResponseStatusCode(response);
    CFDataRef responseDataRef = CFHTTPMessageCopyBody(response);
    NSData *responseData = (__bridge NSData *)responseDataRef;
    NSMutableDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    
    NSLog(@"responseBody: %@", jsonInfo);
}


#pragma mark -
-(HLHTTPResponse*) responseForRequest:(HLHTTPRequest*)request;
{
    NSArray * fileNames = request.body.fileNames;
    NSString * name = [fileNames firstObject];
    if (name) {
        NSString * path = [self.path stringByAppendingPathComponent:name];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithContentsOfFile:path];
        });
    }
    
    return nil;
}


#pragma mark -
+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}




#pragma mark - 测试常驻线程的启动，停止
#pragma mark - Runloop test
static NSThread *cfstreamThread;  // Used for CFStreams
+ (void)ignore:(id)_
{
    
}

+ (void)startCFStreamThreadIfNeeded
{
    cfstreamThread = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(cfstreamThread)
                                               object:nil];
    [cfstreamThread start];
}
+ (void)stopCFStreamThreadIfNeeded
{
    
    // The creation of the cfstreamThread is relatively expensive.
    // So we'd like to keep it available for recycling.
    // However, there's a tradeoff here, because it shouldn't remain alive forever.
    // So what we're going to do is use a little delay before taking it down.
    // This way it can be reused properly in situations where multiple sockets are continually in flux.
    
    int delayInSeconds = 5;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{ @autoreleasepool {
        [cfstreamThread cancel];
        [[self class] performSelector:@selector(ignore:)
                             onThread:cfstreamThread
                           withObject:[NSNull null]
                        waitUntilDone:NO];
    }});
}

+ (void)cfstreamThread { @autoreleasepool
    {
        [[NSThread currentThread] setName:@"cfstreamThread"];
        
        
        // We can't run the run loop unless it has an associated input source or a timer.
        // So we'll just create a timer that will never fire - unless the server runs for decades.
        [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow]
                                         target:self
                                       selector:@selector(ignore:)
                                       userInfo:nil
                                        repeats:YES];
        
        NSThread *currentThread = [NSThread currentThread];
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        
        BOOL isCancelled = [currentThread isCancelled];
        
        while (!isCancelled && [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
        {
            isCancelled = [currentThread isCancelled];
            NSLog(@"循环 %d",isCancelled);
        }
        
    }}
@end

