//
//  VHLJSbrigedHandle.m
//  VHLWebView
//
//  Created by vincent on 16/9/2.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewJSBridgeHandle.h"
#import "VHLWebViewController.h"

@interface VHLWebViewJSBridgeHandle()

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, weak) WKWebView *webView;

@end

@implementation VHLWebViewJSBridgeHandle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithVC:(UIViewController *)viewController jsBridge:(WKWebViewJavascriptBridge *)bridge webView:(WKWebView *)webview {
    if (self = [super init]) {
        self.viewController = viewController;
        self.bridge = bridge;
        self.webView = webview;
    }
    return self;
}
/*
 *  系统相关功能的 JS/Native 交互
 */
- (void)jsSystemHanlde {
    // 是否显示右上角分享按钮 value:0/1   0:不显示，1:显示
    [_bridge registerHandler:@"native_nav_right_show" handler:^(id data, WVJBResponseCallback responseCallback) {
        ((VHLWebViewController *)self.viewController).hideNavMenuBarButton = [data[@"value"] intValue] == 0?YES:NO;
        [((VHLWebViewController *)self.viewController) updateNavigationItems];
    }];
    // 调用分享面板
    [_bridge registerHandler:@"native_share" handler:^(id data, WVJBResponseCallback responseCallback) {
        // url title des cover
        [(VHLWebViewController *)self.viewController navigationMenuButtonClicked];
    }];
    // 网页是否可以回弹 ('native_bounces', {'value': 1}, ...)
    [_bridge registerHandler:@"native_bounces" handler:^(id data, WVJBResponseCallback responseCallback) {
        self.webView.scrollView.bounces = [data[@"value"] intValue] == 1?YES:NO;
    }];
    // pop
    [_bridge registerHandler:@"native_page_pop" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }];
    // 跳转到原生页面
    /**
     {"handlerName":"native_page_push","data":{"class":"vc"}}
     */
    [_bridge registerHandler:@"native_page_push" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data && ![data isKindOfClass:[NSNull class]]) {
            NSString *classNmae = data[@"class"]?:@"";      // ViewController Class
            if (classNmae && ![classNmae isEqualToString:@""]) {
                id newClass = [[NSClassFromString(classNmae) alloc] init];
                if (newClass) {
                    ((UIViewController *)newClass).hidesBottomBarWhenPushed = YES;
                    [self.viewController.navigationController pushViewController:newClass animated:YES];
                } else {
                    responseCallback(@{@"rs":@"0", @"info": @"class 类名错误"});
                }
            } else {
                responseCallback(@{@"rs":@"0", @"info": @"请传入 class 名称"});
            }
        }
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
- (void)jsCallback:(NSDictionary *)data {
    [_bridge callHandler:@"nativeCallback" data:data responseCallback:^(id responseData) {
        NSLog(@"JS Bridge: %@", responseData);
    }];
}

@end
