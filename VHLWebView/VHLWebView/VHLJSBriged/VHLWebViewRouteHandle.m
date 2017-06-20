//
//  VHLWebViewRouteHandle.m
//  VHLWebView
//
//  Created by vincent on 2017/6/19.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewRouteHandle.h"

@interface VHLWebViewRouteHandle()

@property (nonatomic, strong) NSArray *canHandleRoutes;

@end

@implementation VHLWebViewRouteHandle

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static VHLWebViewRouteHandle *routeHandle = nil;
    dispatch_once(&onceToken, ^{
        routeHandle = [[VHLWebViewRouteHandle alloc] init];
        
        routeHandle.canHandleRoutes = @[
                                        // 系统基本功能
                                        @"tel",
                                        @"sms",
                                        @"mailto",
                                        // 系统应用功能
                                        @"sysShake",
                                        // 应用功能
                                        @"pop",            // 导航栏返回          pop://
                                        @"goback",         // 浏览器网页返回       goback://3
                                        @"goforward",      // 浏览器前进          forward://3
                                        @"share"           // 浏览器自带的分享     share://
                                        ];
    });
    return routeHandle;
}
/** 拦截webview url请求，并处理*/
- (BOOL)handlePath:(NSURL *)urlPath vc:(VHLWebViewController *)vc webview:(WKWebView *)webview {
    NSString *scheme =  [urlPath.scheme?:@"" lowercaseString];
    NSString *host = urlPath.host?:@"";
    
    NSString *js = @"";
    
    // 处理拦截的URL
    // 判断是否是系统功能
    if ([@[@"tel", @"sms", @"mailto"] containsObject:scheme]) {
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:urlPath])
        {
            [app openURL:urlPath];
            return YES;
        }
    }
    else if ([scheme isEqualToString:@"sysshake"]) {    // 摇一摇
        js = [NSString stringWithFormat:@"nativeCallback({'type': '%@'})", scheme];
    }
    else if ([scheme isEqualToString:@"pop"]) {         // 导航栏返回
        [vc.navigationController popViewControllerAnimated:YES];
    }
    else if ([scheme isEqualToString:@"goback"]) {      // 浏览器返回
        int gobackpage = [host intValue];
        [self handleGoback:webview page:gobackpage];
    }
    else if ([scheme isEqualToString:@"goforward"]) {   // 浏览器前进
        int forwardpage = [host intValue];
        [self handleGoForward:webview page:forwardpage];
    }
    else if ([scheme isEqualToString:@"share"]) {       // 分享
        [vc navigationMenuButtonClicked];
    }
    
    // 执行 JS 回调
    if (![js isEqualToString:@""]) {
        [webview evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            // result: 当网页注册 nativeCallback 方法后的，return的值
            NSLog(@"执行JS结果:%@，错误:%@", result, [error description]);
        }];
    }
    
    // 拦截
    if ([self.canHandleRoutes containsObject:scheme]) {
        return YES;
    }
    return NO;
}
// -----------------------------------------------------------------------------
// 浏览器返回
- (void)handleGoback:(WKWebView *)webview page:(int)page {
    if (page > 0 && page < 5) {
        for (int i =0; i < page; i++) {
            if (webview.canGoBack) [webview goBack];
            else break;
        }
    }
}
// 浏览器前进
- (void)handleGoForward:(WKWebView *)webview page:(int)page {
    if (page > 0 && page < 5) {
        for (int i = 0; i < page; i++) {
            if (webview.canGoForward) [webview goForward];
            else break;
        }
    }
}

@end
