//
//  VHLWebViewEvaluateJSHandle.h
//  PingLianBank
//
//  Created by vincent on 2017/6/21.
//  Copyright © 2017年 PingLianBank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

/*
    网页加载完成后需要执行的 JS
 */
@interface VHLWebViewEvaluateJSHandle : NSObject
// 单例
+ (instancetype)shareInstance;
// 全局的JS执行
- (void)evaluateJSWebView:(WKWebView *)webview viewController:(UIViewController *)vc;

@end
