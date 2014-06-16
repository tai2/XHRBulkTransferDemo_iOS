//
//  WVTMainViewController.m
//  WebViewVideoTransfer_iOS
//
//  Created by Taiju Muto on 6/13/14.
//  Copyright (c) 2014 Taiju MUto. All rights reserved.
//

#import "XBTMainViewController.h"
#import "XBTSession.h"

#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

static void onAccept(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

@interface XBTMainViewController ()<WVTSessionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (assign, nonatomic) CFSocketRef listen_sock;
@property (retain, nonatomic) NSMutableArray *sessions;

@end

@implementation XBTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.sessions = [[NSMutableArray alloc] init];
    
    NSString *dir_path = [[NSBundle mainBundle] pathForResource:@"html" ofType:nil];
    NSString *html_path = [dir_path stringByAppendingPathComponent:@"index.html"];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:html_path]];
    [self.webview loadRequest:req];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self listen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stop];
}

- (void)listen {
    NSLog(@"listens");
    
    CFSocketContext context = {};
    context.info = (__bridge void *)self;
    
    self.listen_sock = CFSocketCreate(kCFAllocatorDefault,
                                      PF_INET, SOCK_STREAM, IPPROTO_TCP,
                                      kCFSocketAcceptCallBack, onAccept, &context);
    if (!self.listen_sock) {
        abort();
    }
    
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(8080);
    sin.sin_addr.s_addr= INADDR_ANY;
    CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    if (!sincfd) {
        abort();
    }
    
    if (CFSocketSetAddress(self.listen_sock, sincfd) != kCFSocketSuccess) {
        abort();
    }
    
    CFRelease(sincfd);
    
    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.listen_sock, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketsource, kCFRunLoopDefaultMode);
}

- (void)stop {
    NSLog(@"stop");
    
    if (self.listen_sock) {
        CFSocketInvalidate(self.listen_sock);
        CFRelease(self.listen_sock);
        self.listen_sock = NULL;
    }
}

- (void)addSession:(CFSocketNativeHandle)socket {
    XBTSession *session = [[XBTSession alloc] initWithSocket:socket];
    if (session) {
        session.delegate = self;
        [self.sessions addObject:session];
        NSLog(@"session count=%lu", (unsigned long)self.sessions.count);
    } else {
        abort();
    }
}

- (void)didCloseSession:(XBTSession *)session
{
    [self.sessions removeObject:session];
    NSLog(@"session count=%lu", (unsigned long)self.sessions.count);
}

@end

static void onAccept(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    NSLog(@"onAccept");
    
    CFSocketNativeHandle *socket = (CFSocketNativeHandle *)data;
    XBTMainViewController *self = (__bridge XBTMainViewController *)info;
    if (type == kCFSocketAcceptCallBack) {
        [self addSession:*socket];
    }
}