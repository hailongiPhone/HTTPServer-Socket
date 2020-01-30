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

@interface ViewController ()
@property(nonatomic,strong) BaseSocket * bs;
@property(nonatomic,strong) BaseSocket * bc;

@property (nonatomic,strong) HLHTTPServer *httpServer;
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
    
    self.httpServer = [[HLHTTPServer alloc] initWithPort:55667];
}

- (IBAction)onTapButton:(id)sender {
    
    [self.bs setupClinetTCP];
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

#pragma mark - Runloop test
static NSThread *cfstreamThread;  // Used for CFStreams
+ (void)ignore:(id)_
{}

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
