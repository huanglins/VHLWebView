//
//  VHLJSbrigedHandle.m
//  VHLWebView
//
//  Created by vincent on 16/9/2.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewJSBridgeHandle.h"
#import <UIKit/UIKit.h>

@interface VHLWebViewJSBridgeHandle()

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@end

@implementation VHLWebViewJSBridgeHandle

- (instancetype)initWithVC:(UIViewController *)viewController jsBridge:(WKWebViewJavascriptBridge *)bridge {
    if (self = [super init]) {
        self.viewController = viewController;
        self.bridge = bridge;
    }
    return self;
}
/*
 *  系统相关功能的 JS/Native 交互
 */
- (void)jsSystemHanlde
{
    [_bridge registerHandler:@"native_share" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"native_share");
    }];
}
/**
 *  在这里集中处理 JS与OC交互的所有事件。
 */
- (void)jsCustomHandle {
    // 监听
    [_bridge registerHandler:@"plb_public_share" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 回传
        [_bridge callHandler:@"plb_public_share_1" data:data responseCallback:^(id responseData) {
            
        }];
    }];
}
/** JS主动发出消息*/
- (void)jsCallback:(NSDictionary *)data
{
    [_bridge callHandler:@"nativeCallback" data:data responseCallback:^(id responseData) {
        NSLog(@"JS Bridge: %@", responseData);
    }];
}

@end
