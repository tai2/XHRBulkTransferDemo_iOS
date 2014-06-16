//
//  WVTSession.h
//  WebViewVideoTransfer_iOS
//
//  Created by Taiju Muto on 6/14/14.
//  Copyright (c) 2014 Taiju MUto. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RECV_BUFF_SIZE 8192
#define LINE_SIZE 8192

@class XBTSession;

@protocol WVTSessionDelegate

- (void)didCloseSession:(XBTSession *)session;

@end

@interface XBTSession : NSObject

@property (weak, nonatomic) id<WVTSessionDelegate> delegate;

- (instancetype)initWithSocket:(CFSocketNativeHandle)socket;
- (void)close;

@end
