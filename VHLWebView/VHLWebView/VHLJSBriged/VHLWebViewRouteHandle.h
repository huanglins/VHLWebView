//
//  VHLWebViewRouteHandle.h
//  VHLWebView
//
//  Created by vincent on 2017/6/19.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHLWebViewController.h"
#import <WebKit/WebKit.h>

/*
    拦截 url，判断是否能处理
 */
@interface VHLWebViewRouteHandle : NSObject
// 单例
+ (instancetype)shareInstance;

/** 拦截webview url请求，并处理*/
- (BOOL)handlePath:(NSURL *)urlPath vc:(VHLWebViewController *)vc webview:(WKWebView *)webview;

@end
