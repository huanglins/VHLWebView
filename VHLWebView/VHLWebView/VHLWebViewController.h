//
//  VHLWebViewController.h
//  PingLianBank
//
//  Created by vincent on 16/8/23.
//  Copyright © 2016年 PingLianBank. All rights reserved.
//

/**
 *  宏定义,判断是否支持 WKWebKit
 */
#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebKit
#endif

#import <UIKit/UIKit.h>

// iOS 8 以后使用 WKWebView
#import "WKWebViewJavascriptBridge.h"

// runtime objc_requires_super 表示子类继承时必须实现该方法
#ifndef VHL_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define VHL_REQUIRES_SUPER __attribute__((objc_requires_super))
#else
#define VHL_REQUIRES_SUPER
#endif
#endif

NS_ASSUME_NONNULL_BEGIN

@interface VHLWebViewController : UIViewController

// WebKit web view.
@property (nonatomic, readonly) WKWebView *webView;
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

// Url.
@property (nonatomic, readonly) NSURL *URL;
// web title
@property (nonatomic, strong) NSString *webTitle;
// ------------------ 可以设置的属性 ------------------
/** 横屏后是否隐藏状态栏，默认不隐藏。需要在plist中将 View controller-based status bar appearance 设置为 YES */
@property (nonatomic, assign) BOOL hideLandscapeStatusBar;          // 横屏状态栏是否显示 |
/** 是否显示导航栏菜单按钮，默认为不隐藏*/
@property (nonatomic, assign) BOOL hideNavMenuBarButton;            // 导航栏菜单按钮
/** 导航栏返回按钮图片*/
@property (nonatomic, strong) UIImage *navBackButtonImage;          // 导航栏返回按钮图片
/** 导航栏按钮字体样式*/
@property (nonatomic, strong) UIFont  *navButtonTitleFont;          // 导航栏按钮字体大小
/** 导航栏按钮颜色(图片，标题)*/
@property (nonatomic, strong) UIColor *navTitleColor;               // 导航栏按钮颜色(图片，标题)

/** 是否隐藏网页来源lable，默认NO - 显示*/
@property (nonatomic, assign) BOOL hideSourceLabel;                 // 网页来源lable是否显示
/** 网页来源字体颜色，默认为浅灰色*/
@property (nonatomic, strong) UIColor *sourceLabelColor;            // 网页来源lable字体颜色
/** 网页进度条颜色*/
@property (nonatomic, strong) UIColor *progressTintColor;           // 进度条颜色
/** 网页背景层颜色*/
@property (nonatomic, strong) UIColor *webScrollViewBGColor;        // 网页滚动视图背景颜色

/** 当前网页的高度*/
@property (nonatomic, assign, readonly) CGFloat htmlHeight;         // 当前网页的高度
/** 分享到QQ等因为是新闻类型，需要传一个封面Image过去*/
@property (nonatomic, strong) UIImage *shareCoverImage;             // 分享显示的封面图片

// ---------------------------------------------------

// init
- (instancetype)initWithAddress:(NSString *)urlString;
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL;
- (instancetype)initWithRequest:(NSMutableURLRequest *)request;
- (instancetype)initWithPostRequestURL:(NSString *)url postData:(NSDictionary *)parameters title:(NSString *)title;
// 请求 url/request/post
- (void)loadAddress:(NSString *)urlString;
- (void)loadURL:(NSURL *)URL;
- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL;
- (void)loadRequest:(NSMutableURLRequest *)request;
- (void)loadPostRequestURL:(NSString *)url postData:(NSDictionary *)parameters title:(NSString *)title;
/** 执行JS*/
- (void)evaluateJavaScript:(NSString *)js;
/** 调用右上角分享*/
- (void)navigationMenuButtonClicked;
// 子类可以重写该方法
- (void)willGoBack VHL_REQUIRES_SUPER;
- (void)willGoForward VHL_REQUIRES_SUPER;
- (void)willReload VHL_REQUIRES_SUPER;
- (void)willStop VHL_REQUIRES_SUPER;
- (void)didStartLoad VHL_REQUIRES_SUPER;
- (void)didFinishLoad VHL_REQUIRES_SUPER;
- (void)didFailLoadWithError:(NSError *)error VHL_REQUIRES_SUPER;

// JS 交互
/*
 根据实际情况重写
 VHLWebViewEvaluateJSHandle
 VHLWebViewJSBridgeHandle
 VHLWebViewRouteHandle
 中的方法
 */

@end
NS_ASSUME_NONNULL_END


/*
    使用须知：
    1.Pods
        导入库
        pod 'FDFullscreenPopGesture', '1.1'
        pod 'WebViewJavascriptBridge', '~> 5.0'
    
    2.预先写入 UINavigationBar 样式
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0]];
        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1.00],NSForegroundColorAttributeName, [UIFont systemFontOfSize:16],NSFontAttributeName , nil] forState:0];
        [[UINavigationBar appearance]setBarTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"vhl_nav_back"]];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"vhl_nav_back"]];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -2) forBarMetrics:UIBarMetricsDefault];
    3. 使用了 OpenShare 分享
        AppDeleate 中
            [OpenShare connectQQWithAppId:@"1103194207"];
            [OpenShare connectWeixinWithAppId:@"wx4380971b4ff92e6d"];
 
            -(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
 
                //第二步：添加回调 - 判断分享是否能处理回调
                if ([OpenShare handleOpenURL:url]) {
                    return YES;
                }
                // 判断是否能处理其他回调
                //这里可以写上其他OpenShare不支持的客户端的回调，比如支付宝等。
                return YES;
            }
    4.  WebViewJavascriptBridge JS交互
        监听和回调在 VHLJSBridgeHandle 中进行集中处理
        参考：https://github.com/marcuswestin/WebViewJavascriptBridge
    5.
 */

/*
 request 
 
 NSString *loginUrl = @"https://just2us.com/login";
 NSURL *url = [NSURL URLWithString:loginUrl];
 NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
 
 // POST the username password
 [requestObj setHTTPMethod:@"POST"];
 NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", @"samwize", @"secret"];
 NSData *data = [postString dataUsingEncoding: NSUTF8StringEncoding];
 [requestObj setHTTPBody:data];
 
 */
