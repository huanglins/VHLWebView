//
//  VHLJSbrigedHandle.h
//  VHLWebView
//
//  Created by vincent on 16/9/2.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebKit
#endif

//
#import "WKWebViewJavascriptBridge.h"

/**
 *  通过 JavascriptBridge 进行原生交互。
 */
@interface VHLWebViewJSBridgeHandle : NSObject

- (instancetype)initWithVC:(UIViewController *)viewController jsBridge:(WKWebViewJavascriptBridge *)bridge webView:(WKWebView *)webview;

/*
 *  系统相关功能的 JS/Native 交互
 */
- (void)jsSystemHanlde;
/**
 *  自定义业务相关的 JS/Native 交互
 */
- (void)jsCustomHandle;

/** JS主动发出消息*/
- (void)jsCallback:(NSDictionary *)data;

@end
