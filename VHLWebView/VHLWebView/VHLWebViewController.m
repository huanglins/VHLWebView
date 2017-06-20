//
//  VHLWebViewController.m
//  PingLianBank
//
//  Created by vincent on 16/8/23.
//  Copyright © 2016年 PingLianBank. All rights reserved.
//

#import "VHLWebViewController.h"
#import <objc/runtime.h>
#import <Aspects/Aspects.h>
//#import <UINavigationController+FDFullscreenPopGesture.h>
#import <MessageUI/MessageUI.h> // 邮件
// Share
#import "OpenShare.h"
#import "OpenShare+Weixin.h"
#import "OpenShare+QQ.h"
// menu
#import "VHLWebViewShareView.h"
#import "VHLWebViewChangeFontView.h"
// route/js handle
#import "VHLWebViewJSBridgeHandle.h"
#import "VHLWebViewRouteHandle.h"

#define VHLWEB_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// -----------------------------------------------------------------------------
// 定义一个进度的扩展
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@interface UIProgressView (WebKit)
// Hidden when progress approach 1.0 Default is NO.
@property (nonatomic, assign) BOOL vhl_hiddenWhenProgressApproachFullSize;
@end

@interface VHLWebViewController()
@property (nonatomic, strong) WKNavigation *navigation;                 // 当前网页导航栏
@property (nonatomic, strong) UIProgressView *progressView;             // 网页进度条

@property (nonatomic, strong) VHLWebViewJSBridgeHandle *vhlJSBridgeHandle;
@end

@implementation UIProgressView (WebKit)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(setProgress:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(vhl_setProgress:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalMethod = class_getInstanceMethod(self, @selector(setProgress:animated:));
        swizzledMethod = class_getInstanceMethod(self, @selector(vhl_setProgress:animated:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)vhl_setProgress:(float)progress {
    [self vhl_setProgress:progress];
    
    [self v_checkHiddenWhenProgressApproachFullSize];
}
- (void)vhl_setProgress:(float)progress animated:(BOOL)animated {
    [self vhl_setProgress:progress animated:animated];
    
    [self v_checkHiddenWhenProgressApproachFullSize];
}

- (void)v_checkHiddenWhenProgressApproachFullSize {
    if (!self.vhl_hiddenWhenProgressApproachFullSize) {
        return;
    }
    
    float progress = self.progress;
    if (progress < 1) {
        if (self.hidden) {
            self.hidden = NO;
        }
    } else if (progress >= 1) {
        [UIView animateWithDuration:0.35 delay:0.15 options:7 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.hidden = YES;
                self.progress = 0.0;
                self.alpha = 1.0;
            }
        }];
    }
}
- (BOOL)vhl_hiddenWhenProgressApproachFullSize {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setVhl_hiddenWhenProgressApproachFullSize:(BOOL)vhl_hiddenWhenProgressApproachFullSize{
    objc_setAssociatedObject(self, @selector(vhl_hiddenWhenProgressApproachFullSize), @(vhl_hiddenWhenProgressApproachFullSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
#endif
// -----------------------------------------------------------------------------

@interface VHLWebViewController () <WKUIDelegate, WKNavigationDelegate,UIScrollViewDelegate,MFMailComposeViewControllerDelegate>
{
    BOOL _loading;
    BOOL _didMakePostRequest;       // 是否加载POST请求
    UIBarButtonItem * __weak _doneItem;
    
    NSString *_HTMLString;
    NSURL *_baseURL;
    NSMutableURLRequest *_urlRequest;
    NSString *_postJScript;
    
    int _webTextSizeAdjust;     // 网页字体大小(1-5，2为标准)
}
@property (nonatomic, strong) UIBarButtonItem *navBackBarButtonItem;    // 左边返回导航栏按钮
@property (nonatomic, strong) UIBarButtonItem *navCloseBarButtonItem;   // 左边关闭导航栏按钮
@property (nonatomic, strong) UIBarButtonItem *navMenuBarButtonItem;    // 右边菜单按钮

@property (nonatomic, strong) UILabel *backgroundLabel;                 // 显示 - 网页有 *** 提供
@property (nonatomic, strong) NSTimer *updating;                        // 定时器

@end

#ifndef kVHL404NotFoundHTMLPath
#define kVHL404NotFoundHTMLPath [[NSBundle mainBundle] pathForResource:@"vhlwebhtml.bundle/404" ofType:@"html"]
#endif
#ifndef kVHLNetworkErrorHTMLPath
#define kVHLNetworkErrorHTMLPath [[NSBundle mainBundle] pathForResource:@"vhlwebhtml.bundle/neterror" ofType:@"html"]
#endif
#ifndef kVHLPOSTHTMLPath
#define kVHLPOSTHTMLPath [[NSBundle mainBundle] pathForResource:@"vhlwebhtml.bundle/post" ofType:@"html"]
#endif
static NSString* const kVHL404NotFoundURLKey  = @"vhl_404_not_found";
static NSString* const kVHLNetworkErrorURLKey = @"vhl_network_error";
// 本地存储key
static NSString* const kVHLWebTextSizeAdjustUD = @"cn.vincents.vhlwebview.webTextSizeAdjust";

@implementation VHLWebViewController
@synthesize URL = _URL, webView = _webView, webTitle = _webTitle;

#pragma mark - Life cycle 生命周期
- (void)dealloc{
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    
    _webView = nil;
}
- (instancetype)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}
- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        _URL = URL;
    }
    return self;
}
- (instancetype)initWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL {
    if (self = [super init]) {
        _HTMLString = HTMLString;
        _baseURL = baseURL;
    }
    return self;
}
- (instancetype)initWithRequest:(NSMutableURLRequest *)request {
    if (self = [super init]) {
        _urlRequest = request;
    }
    return self;
}
- (instancetype)initWithPostRequestURL:(NSString *)url postData:(NSDictionary *)parameters title:(NSString *)title
{
    if (self = [super init]) {
        _webTitle = title;
        self.navigationItem.title = _webTitle;
        
        _HTMLString = [[NSString alloc] initWithContentsOfFile:kVHLPOSTHTMLPath encoding:NSUTF8StringEncoding error:nil];
        _baseURL = [[NSBundle mainBundle] bundleURL];
        
        _didMakePostRequest = YES;
        // 构建需要执行的JS
        NSMutableString *parametersStr = [NSMutableString string];
        for (NSString *key in parameters.allKeys) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            //含警告的代码,如下,btn为UIButton类型的指针
            NSString *value = [parameters[key?:@""]?:@"" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
            #pragma clang diagnostic pop
            [parametersStr appendString:[NSString stringWithFormat:@"\"%@\":\"%@\",", key, value]];
        }
        parametersStr = (NSMutableString *)[parametersStr substringToIndex:parametersStr.length - 1];
        _postJScript = [NSString stringWithFormat:@"post('%@', {%@});", url, parametersStr];
    }
    return self;
}
#pragma mark - 0---------------------------------------------------------------0
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.automaticallyAdjustsScrollViewInsets = YES;                        // 自动调整 inset
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    // self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self setupSubviews];
    
    if (_URL) {
        [self loadURL:_URL];
    } else if (_HTMLString && _baseURL) {
        [self loadHTMLString:_HTMLString baseURL:_baseURL];
    } else if (_urlRequest) {
        [self loadRequest:_urlRequest];
    }
    // 网页字体获取
    _webTextSizeAdjust = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kVHLWebTextSizeAdjustUD];
    if (_webTextSizeAdjust <= 0) {
        _webTextSizeAdjust = 2;
    }

    self.view.backgroundColor = [UIColor whiteColor];
    self.progressView.progressTintColor = self.progressTintColor?:self.navigationController.navigationBar.tintColor;
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

    // 指定leftButton 和 backButton 可以同时显示。其中leftButton显示在backButton的右边
    // self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.navBackBarButtonItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        [self updateFrameOfProgressView];
        [self.navigationController.navigationBar addSubview:self.progressView];
    }
    // 模态跳转
    if (self.navigationController && [self.navigationController isBeingPresented]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.navigationItem.leftBarButtonItem = doneButton;
        else
            self.navigationItem.rightBarButtonItem = doneButton;
        _doneItem = doneButton;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateNavigationItems];
    // ----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----
    // ----- 监听屏幕设备旋转 -----
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.navigationController) {
        [_progressView removeFromSuperview];
    }
    
    // 移除通知
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationItem setLeftBarButtonItems:nil animated:NO];
}
#pragma mark - 屏幕旋转相关方法    ------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateNavigationItems];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if ([super respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    }
    [self updateNavigationItems];
}
- (void)orientationChanged:(NSNotification *)note  {
    [self updateNavigationItems];
}
//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    return self.hideLandscapeStatusBar;
}
#pragma mark - VHLPopNavigationController 注入方法  -----------------------------
// 用于实现自定义的导航栏返回按钮点击
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    // Should not pop. It appears clicked the back bar button item. We should decide the action according to the content of web view.
    if ([self.navigationController.topViewController isKindOfClass:[VHLWebViewController class]]) {
        VHLWebViewController* webVC = (VHLWebViewController*)self.navigationController.topViewController;
        // If web view can go back.
        if (webVC.webView.canGoBack) {
            // Stop loading if web view is loading.
            if (webVC.webView.isLoading) {
                [webVC.webView stopLoading];
            }
            // Go back to the last page if exist.
            [webVC.webView goBack];
            // Should not pop items.
            return NO;
        }else{
            // Pop view controlers directly.
            return YES;
        }
    }else{
        // Pop view controllers directly.
        return YES;
    }
}
#pragma mark - KVO 键值监听相关   ------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    // 监听网页加载进度
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.navigationController && self.progressView.superview != self.navigationController.navigationBar) {
            [self updateFrameOfProgressView];
            [self.navigationController.navigationBar addSubview:self.progressView];
        }
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (progress >= _progressView.progress) {
            [_progressView setProgress:progress animated:YES];
        } else {
            [_progressView setProgress:progress animated:NO];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - Public 公开调用的方法   -------------------------------------------
- (void)loadAddress:(NSString *)urlString{
    [self loadURL:[NSURL URLWithString:urlString]];
}
- (void)loadURL:(NSURL *)URL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    _navigation = [_webView loadRequest:request];
}
- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    _HTMLString = HTMLString;
    _navigation = [_webView loadHTMLString:HTMLString baseURL:baseURL];
}
- (void)loadRequest:(NSMutableURLRequest *)request {
    _URL = request.URL;
    _navigation = [_webView loadRequest:request];
}
- (void)loadPostRequestURL:(NSString *)url postData:(NSDictionary *)parameters title:(NSString *)title{
    _webTitle = title;
    self.navigationItem.title = _webTitle;
    
    _HTMLString = [[NSString alloc] initWithContentsOfFile:kVHLPOSTHTMLPath encoding:NSUTF8StringEncoding error:nil];
    _baseURL = [[NSBundle mainBundle] bundleURL];
    
    _didMakePostRequest = YES;
    // 构建需要执行的JS
    NSMutableString *parametersStr = [NSMutableString string];
    for (NSString *key in parameters.allKeys) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            //含警告的代码,如下,btn为UIButton类型的指针
        NSString *value = parameters[key];
        value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        #pragma clang diagnostic pop
        [parametersStr appendString:[NSString stringWithFormat:@"\"%@\":\"%@\",", key, value]];
    }
    parametersStr = (NSMutableString *)[parametersStr substringToIndex:parametersStr.length - 1];
    _postJScript = [NSString stringWithFormat:@"post('%@', {%@});", url, parametersStr];
    
    [self loadHTMLString:_HTMLString baseURL:_baseURL];
}
- (void)evaluateJavaScript:(NSString *)js
{
    [self.webView evaluateJavaScript:js completionHandler:^(id object, NSError * _Nullable error) {
        _didMakePostRequest = NO;
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:error.userInfo[@"WKJavaScriptExceptionMessage"]?:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:NULL];
            }];
            // add actions
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:^{}];
        }
    }];
}
#pragma mark - 拼接cookie
- (NSString *)readCurrentCookieWith:(NSDictionary*)dic{
    if (dic == nil) {
        return nil;
    }else{
        NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSMutableString *cookieString = [[NSMutableString alloc] init];
        for (NSHTTPCookie*cookie in [cookieJar cookies]) {
            [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
        }
        //删除最后一个“;”
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
        return cookieString;
    }
}
#pragma mark - 集中处理的网页方法    ----------------------------------------------
// 回调 - 网页将要回退
- (void)willGoBack {
    
}
// 回调 - 网页将要向前
- (void)willGoForward {

}
// 回调 - 网页重新加载
- (void)willReload {

}
// 回调 - 网页将要结束
- (void)willStop {

}
// 回调 - 网页开始加载
- (void)didStartLoad {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateNavigationItems];
    // 开始加载的时候，让进度条先前进一点
    [self.progressView setProgress:0.16 animated:YES];
    if (_didMakePostRequest) {
        [_progressView setProgress:0.88 animated:YES];
    }

    _loading = YES;
}
// 回调 - 网页加载完成
- (void)didFinishLoad {
    @try {
        [self hookWebContentCommitPreviewHandler];
    } @catch (NSException *exception) {
    } @finally {
    }
    _loading = NO;
    // 网页加载转圈停止
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    // 修改导航栏按钮
    [self updateNavigationItems];
    // 网页背景颜色
    {
        //self.view.backgroundColor = _webScrollViewBGColor?:[UIColor colorWithRed:0.53 green:0.56 blue:0.62 alpha:1.00];
        _webView.backgroundColor = _webScrollViewBGColor?:[UIColor clearColor];
    }
    // 网页来源显示
    {
        NSString *title;
        title = [_webView title]?:@"";

        if ([title isEqualToString:@""]) {
            self.navigationItem.title = _webTitle?:@"";
        } else {
            self.navigationItem.title = title;
        }
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *bundle = ([infoDictionary objectForKey:@"CFBundleDisplayName"]?:[infoDictionary objectForKey:@"CFBundleName"])?:[infoDictionary objectForKey:@"CFBundleIdentifier"];
        NSString *host;
        host = _webView.URL.host;

        _backgroundLabel.text = [NSString stringWithFormat:@"此网页由 %@ 提供", host?:bundle]; //
    }
    // 修改当前网页字体
    {
        int scaleValue = 100;
        if (_webTextSizeAdjust == 1) {
            scaleValue = 90;
        } else if (_webTextSizeAdjust == 2) {
            scaleValue = 100;
        } else if (_webTextSizeAdjust == 3) {
            scaleValue = 110;
        } else if (_webTextSizeAdjust == 4) {
            scaleValue = 120;
        } else if (_webTextSizeAdjust == 5) {
            scaleValue = 130;
        }
        NSString *jsStr = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='%d%%'",scaleValue];
    
        [self.webView evaluateJavaScript:jsStr completionHandler:nil];
    }
    // 获取当前网页内容高度
    {
        _htmlHeight = _webView.scrollView.contentSize.height;
    }
}
// 回调 - 网页请求错误
- (void)didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorCannotFindHost) {   // 404
        [self loadURL:[NSURL fileURLWithPath:kVHL404NotFoundHTMLPath]];
    } else if(error.code == NSURLErrorNotConnectedToInternet){
        [self loadURL:[NSURL fileURLWithPath:kVHLNetworkErrorHTMLPath]];
    }
    
    [self updateNavigationItems];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //[_progressView setProgress:0.9 animated:YES];
    if (error.code == -999) {   // -999 上一页面还没加载完，就加载当下一页面，就会报这个错。
        return;
    } else {
        _backgroundLabel.text = [NSString stringWithFormat:@"网页加载失败:%@",error.localizedDescription];
        // 弹框提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:error.userInfo[@"WKJavaScriptExceptionMessage"]?:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:NULL];
        }];
        // add actions
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:^{}];
    }
}
#pragma mark - Actions   -------------------------------------------------------
// 点击回退
- (void)goBackClicked:(UIBarButtonItem *)sender {
    [self willGoBack];

    if ([_webView canGoBack]) {
        _navigation = [_webView goBack];
    }
}
// 点击向前
- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [self willGoForward];
    if ([_webView canGoForward]) {
        _navigation = [_webView goForward];
    }
}
// 点击重新加载
- (void)reloadClicked:(UIBarButtonItem *)sender {
    [self willReload];
    
    if ([_webView.URL.resourceSpecifier isEqualToString:kVHL404NotFoundHTMLPath] ||
        [_webView.URL.resourceSpecifier isEqualToString:kVHLNetworkErrorHTMLPath])
    {
        [self loadURL:_URL];
    } else {
        _navigation = [_webView reload];
    }
}
// 点击停止网页加载
- (void)stopClicked:(UIBarButtonItem *)sender {
    [self willStop];
    [_webView stopLoading];
}
#pragma mark - 导航栏相关的点击方法 -----------------------------------------------
// 导航栏返回按钮点击
- (void)navigationItemHandleBack:(UIBarButtonItem *)sender {
    if ([_webView canGoBack]) {
        _navigation = [_webView goBack];
        return;
    }
    // 模态跳转和导航栏跳转
    if (self.navigationController && [self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
// 导航栏关闭按钮点击
- (void)navigationIemHandleClose:(UIBarButtonItem *)sender {
    // 模态跳转和导航栏跳转
    if (self.navigationController && [self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
// 导航栏关闭按钮点击,模态跳转时
- (void)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
// 导航栏菜单按钮点击，分享
- (void)navigationMenuButtonClicked {
    // 取消当前编辑
    [self.webView endEditing:YES];
    // 1.
    VHLWebViewShareItem *item0 = [VHLWebViewShareItem itemWithTitle:@"微信"
                                                               icon:@"vhl_webview_share_weixin"
                                                            handler:^{
                                                                OSMessage *msg=[[OSMessage alloc] init];

                                                                msg.title = self.webView.title;
                                                                msg.link=self.webView.URL.absoluteString;

                                                                msg.desc = @"";
                                                                
                                                                msg.image=[UIImage new];
                                                                msg.multimediaType=OSMultimediaTypeNews;
                                                                
                                                                [OpenShare shareToWeixinSession:msg Success:^(OSMessage *message) {
                                                                    NSLog(@"微信分享到会话成功：\n%@",message);
                                                                } Fail:^(OSMessage *message, NSError *error) {
                                                                    NSLog(@"微信分享到会话失败：\n%@\n%@",error,message);
                                                                }];
                                                            }];
    VHLWebViewShareItem *item1 = [VHLWebViewShareItem itemWithTitle:@"朋友圈"
                                                               icon:@"vhl_webview_share_timeline"
                                                            handler:^{
                                                                OSMessage *msg=[[OSMessage alloc] init];
                                                                msg.title = self.webView.title;
                                                                msg.link=self.webView.URL.absoluteString;

                                                                msg.desc = @"";
                                                                msg.image = [UIImage new];
                                                                msg.multimediaType=OSMultimediaTypeNews;
                                                                
                                                                [OpenShare shareToWeixinTimeline:msg Success:^(OSMessage *message) {
                                                                    NSLog(@"微信分享到会话成功：\n%@",message);
                                                                } Fail:^(OSMessage *message, NSError *error) {
                                                                    NSLog(@"微信分享到会话失败：\n%@\n%@",error,message);
                                                                }];
                                                            }];
    VHLWebViewShareItem *item2 = [VHLWebViewShareItem itemWithTitle:@"QQ"
                                                               icon:@"vhl_webview_share_qq"
                                                            handler:^{
                                                                OSMessage *msg=[[OSMessage alloc] init];
                                                                msg.title = self.webView.title;
                                                                msg.link=self.webView.URL.absoluteString;

                                                                msg.desc = @"";
                                                                UIImage *image = _shareCoverImage?:[UIImage imageNamed:@"vhl_webview_share_qq"];
                                                                msg.image=image;
                                                                msg.thumbnail = image;
                                                                
                                                                [OpenShare shareToQQFriends:msg Success:^(OSMessage *message) {
                                                                    NSLog(@"QQ分享到会话成功：\n%@",message);
                                                                } Fail:^(OSMessage *message, NSError *error) {
                                                                    
                                                                }];
                                                            }];
    VHLWebViewShareItem *item3 = [VHLWebViewShareItem itemWithTitle:@"QQ空间"
                                                               icon:@"vhl_webview_share_qzone"
                                                            handler:^{
                                                                OSMessage *msg=[[OSMessage alloc] init];
                                                                
                                                                msg.title = self.webView.title;
                                                                msg.link=self.webView.URL.absoluteString;

                                                                msg.desc = @"";
                                                                UIImage *image = _shareCoverImage?:[UIImage imageNamed:@"vhl_webview_share_qq"];
                                                                msg.image=image;
                                                                msg.thumbnail = image;
                                                                
                                                                [OpenShare shareToQQZone:msg Success:^(OSMessage *message) {
                                                                    NSLog(@"QQ分享到会话成功：\n%@",message);
                                                                } Fail:^(OSMessage *message, NSError *error) {
                                                                    NSLog(@"QQ分享到会话失败：\n%@\n%@",error,message);
                                                                }];
                                                            }];
    VHLWebViewShareItem *item4 = [VHLWebViewShareItem itemWithTitle:@"邮件"
                                                               icon:@"vhl_webview_share_email"
                                                            handler:^{
                                                                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                                                                mailViewController.mailComposeDelegate = self;
                                                                    [mailViewController setSubject:[self.webView title]];
                                                                    if ([self.webView.URL.scheme isEqualToString:@"file"]) {
                                                                        [mailViewController setMessageBody:self.URL.absoluteString isHTML:NO];
                                                                    } else {
                                                                        [mailViewController setMessageBody:self.webView.URL.absoluteString isHTML:NO];
                                                                    }

                                                                mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                                                                
                                                                [self presentViewController:mailViewController animated:YES completion:nil];
                                                            }];
    VHLWebViewShareItem *item5 = [VHLWebViewShareItem itemWithTitle:@"在Safari中打开"
                                                               icon:@"vhl_webview_share_safari"
                                                            handler:^{
                                                                [[UIApplication sharedApplication] openURL:_URL];
                                                            }];
    // 2. 功能按钮 [复制链接，修改字体，刷新]
    VHLWebViewShareItem *item11 = [VHLWebViewShareItem itemWithTitle:@"复制链接"
                                               icon:@"vhl_webview_action_copylink"
                                            handler:^{
                                                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                
                                                if ([self.webView.URL.scheme isEqualToString:@"file"]) {
                                                    pasteboard.string = self.URL.absoluteString?:@"www.vincents.cn";
                                                } else {
                                                    pasteboard.string = self.webView.URL.absoluteString?:@"www.vincents.cn";
                                                }
                                                // 弹出提示
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"链接已经复制" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                                [self presentViewController:alert animated:YES completion:^{
                                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC));
                                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                    });
                                                }];
                                            }];
    VHLWebViewShareItem *item12 = [VHLWebViewShareItem itemWithTitle:@"字体"
                                                                icon:@"vhl_webview_action_font"
                                                             handler:^{
                                                                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                 VHLWebViewChangeFontView *changeFontView = [[VHLWebViewChangeFontView alloc] init];
                                                                 [changeFontView setSliderValue:_webTextSizeAdjust];
                                                                 [changeFontView show];
                                                                 [changeFontView changeSize:^(CGFloat stepValue) {
                                                                     // 保存
                                                                     _webTextSizeAdjust = stepValue;
                                                                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                                     [userDefaults setInteger:_webTextSizeAdjust forKey:kVHLWebTextSizeAdjustUD];
                                                                     [userDefaults synchronize];
                                                                     //
                                                                     int scaleValue = 100;
                                                                     if (_webTextSizeAdjust == 1) {
                                                                         scaleValue = 90;
                                                                     } else if (_webTextSizeAdjust == 2) {
                                                                         scaleValue = 100;
                                                                     } else if (_webTextSizeAdjust == 3) {
                                                                         scaleValue = 110;
                                                                     } else if (_webTextSizeAdjust == 4) {
                                                                         scaleValue = 120;
                                                                     } else if (_webTextSizeAdjust == 5) {
                                                                         scaleValue = 130;
                                                                     }
                                                                     
                                                                     NSString *jsStr = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='%d%%'",scaleValue];
                                                                    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                                                                     
                                                                    [self.webView evaluateJavaScript:jsStr completionHandler:nil];
                                                                    #else
                                                                     [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
                                                                    #endif
                                                                 }];
                                                             }];
    VHLWebViewShareItem *item13 = [VHLWebViewShareItem itemWithTitle:@"刷新"
                                                               icon:@"vhl_webview_action_refresh"
                                                            handler:^{
                                                                [self reloadClicked:nil];
                                                            }];
    NSArray *shareItemsArray = @[item0,item1,item2,item3,item4,item5];
    if (!_URL) {        // 如果没有URL，那么就不显示 [在Safari打开]
        shareItemsArray = @[item0,item1,item2,item3,item4];
    }
    NSArray *functionItemsArray = @[item11,item12,item13];
    //
    VHLWebViewShareView *shareView = [VHLWebViewShareView shareViewWithShareItems:shareItemsArray funcationItems:functionItemsArray];
    shareView.titleLabel.text = self.backgroundLabel.text;
    [shareView show];
}
#pragma mark - ALL Delegate -------------------------------- **** --------------------------------
#pragma mark MFMailComposeViewControllerDelegate   --- 发送邮件的代理
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#pragma mark - WKUIDelegate
// WKUI - Delegate - 0.创建一个webview
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if (navigationAction.request) {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
// WKUI - Delegate - 1.网页已经关闭
- (void)webViewDidClose:(WKWebView *)webView {
}
// WKUI - Delegate - 1.网页将要关闭，网页内容将要被终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
    // Get the host name.
    NSString *host = webView.URL.host;
    // Initialize alert view controller.
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:host?:@"来自网页的消息" message:@"网页进程终止" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
    }];
    // Add actions.
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#endif
// WKUI - Delegate - 2.警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // Get host name of url
    NSString *host = webView.URL.host;
    // Init the alert view controller
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:host?:@"来自网页的消息" message:message preferredStyle:UIAlertControllerStyleAlert];
    //UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        completionHandler();
    }];
    // add actions
    //[alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
// WKUI - Delegate - 2.确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    // Get host name of url
    NSString *host = webView.URL.host;
    // Init the alert view controller
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:host?:@"来自网页的消息" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        completionHandler(YES);
    }];
    // add actions
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
// WKUI - Delegate - 2.输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    // Get the host of url.
    NSString *host = webView.URL.host;
    // Initialize alert view controller.
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:prompt?:@"来自网页的消息" message:host preferredStyle:UIAlertControllerStyleAlert];
    // Add text field.
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText?:@"输入文字消息";
        textField.font = [UIFont systemFontOfSize:12];
    }];
    // Initialize cancel action.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        // Get inputed string.
        NSString *string = [alert.textFields firstObject].text;
        completionHandler(string?:defaultText);
    }];
    // Initialize ok action.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        // Get inputed string.
        NSString *string = [alert.textFields firstObject].text;
        completionHandler(string?:defaultText);
    }];
    // Add actions.
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
#pragma mark - WKNavigationDelegate
// WKNavigation - Delegate - 1.开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self didStartLoad];
}
// WKNavigation - Delegate - 1.已经开始加载页面
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    // 请求成功 前进或者后退
    [self updateNavigationItems];
}
// WKNavigation - Delegate - 1.网页请求成功
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    // 如果需要加载POST
    if (_didMakePostRequest) {
        // ** 这里因为 html里面的动画延时为0.5秒，需要等加载动画都执行后在去执行JS，不然动画不会执行**
        [self performSelector:@selector(evaluateJavaScript:) withObject:_postJScript afterDelay:0.5];
    }
    [self didFinishLoad];
}
// WKNavigation - Delegate - 1.请求出现错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self didFailLoadWithError:error];
}
// WKNavigation - Delegate - 1.网页请求错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self didFailLoadWithError:error];
}
// WKNavigation - Delegate - 2.发送请求之前，决定是否跳转，可以拦截URL
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // Disable all the '_blank' target in page's target.
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    // 即将请求的路径
    NSURL         *url = navigationAction.request.URL;
    // 拦截url处理
    if ([[VHLWebViewRouteHandle shareInstance] handlePath:url vc:self webview:webView]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // URL actions
    if ([navigationAction.request.URL.absoluteString hasSuffix:kVHL404NotFoundURLKey] || [navigationAction.request.URL.absoluteString hasSuffix:kVHLNetworkErrorURLKey]) {
        [self loadURL:_URL];
    }
    [self updateNavigationItems];
    decisionHandler(WKNavigationActionPolicyAllow);
}
// WKNavigation - Delegate - 2.收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// WKNavigation - Delegate - 2.接收到服务器跳转请求后(手势侧滑返回完成)
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    // WKWebView 通过侧滑手势返回了一个页面
    [self updateNavigationItems];
}
// WK - Delegate - 3.处理认证和代理
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}
#endif
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}
#pragma mark - Getters  ------------------------------------------------------------------------------------------------------
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
- (WKWebView *)webview {
    if (_webView) return _webView;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 设置网页最小的字体，默认为0
    config.preferences.minimumFontSize = 9.0;
    // 默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 是否支持记忆读取
    config.suppressesIncrementalRendering = YES;
    //
    
    // ------ ** 设置cookie ** ------
    // web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    // 将所有cookie以document.cookie = 'key=value';形式进行拼接
    // 然而这里的单引号一定要注意是英文的，不要问我为什么告诉你这个(手动微笑)
    NSString *cookieValue = @"document.cookie = 'fromapp=ios';document.cookie = 'channel=appstore';";
    
    // 加cookie给h5识别，表明在ios端打开该地址; 解决后续页面(同域)Ajax、iframe 请求的 Cookie 问题
    WKUserContentController* userContentController = WKUserContentController.new;
    WKUserScript * cookieScript = [[WKUserScript alloc]
                                   initWithSource: cookieValue
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    config.userContentController = userContentController;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    // 设置网页的 UserAgent（用户代理）- 将当前应用程序的名称设置为UserAgent
    if ([config respondsToSelector:@selector(setApplicationNameForUserAgent:)]) {
        [config setApplicationNameForUserAgent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    }
    // 内联媒体播放的回调,自动播放
    if ([config respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
        [config setAllowsInlineMediaPlayback:YES];
    }
#endif
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    _webView.allowsBackForwardNavigationGestures = YES;                         // 左划回退
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    if ([_webView respondsToSelector:@selector(setAllowsLinkPreview:)]) {
        _webView.allowsLinkPreview = NO;                                        // 禁用3DTouch 预览
    }
    #endif
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.backgroundColor = [UIColor clearColor];
    // 设置使用自动布局
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    _webView.scrollView.delegate = self;
    
    return _webView;
}
- (UIProgressView *)progressView {
    if (_progressView) return _progressView;
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.trackTintColor = [UIColor clearColor];
    _progressView.vhl_hiddenWhenProgressApproachFullSize = YES;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return _progressView;
}
#endif

// 网页由 ** 提供
- (UILabel *)backgroundLabel {
    if (_backgroundLabel) return _backgroundLabel;
    _backgroundLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _backgroundLabel.textColor = _sourceLabelColor?:[UIColor colorWithRed:0.6039 green:0.6039 blue:0.6039 alpha:1.0];
    _backgroundLabel.font = [UIFont systemFontOfSize:12];
    _backgroundLabel.numberOfLines = 0;
    _backgroundLabel.textAlignment = NSTextAlignmentCenter;
    _backgroundLabel.backgroundColor = [UIColor clearColor];
    _backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    return _backgroundLabel;
}
// 导航栏 [返回] 按钮
- (UIBarButtonItem *)navBackBarButtonItem {
    if (_navBackBarButtonItem) return _navBackBarButtonItem;
    // UIImageRenderingModeAlwaysTemplate 模式，图片根据 tint color
    UIImage* backItemImage = self.navBackButtonImage?:([[[UINavigationBar appearance] backIndicatorImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]?:[[UIImage imageNamed:@"vhl_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
    if (self.navTitleColor) {
        UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, backItemImage.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGRect rect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
        CGContextClipToMask(context, rect, backItemImage.CGImage);
        [self.navTitleColor setFill];
        CGContextFillRect(context, rect);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        backItemImage = newImage?:backItemImage;
    }
    
    // 绘制高亮的背景
    UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, backItemImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
    CGContextClipToMask(context, rect, backItemImage.CGImage);
    if (self.navTitleColor) {
        [[self.navTitleColor colorWithAlphaComponent:0.5] setFill];
    } else {
        [[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] setFill];
    }
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* backItemHlImage = newImage?:[[UIImage imageNamed:@"vhl_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // -----------------------------------------------------------
    
    UIButton *backButton = [[UIButton alloc] init];
    // 按钮图片
    [backButton setImage:backItemImage forState:UIControlStateNormal];
    [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
    // 按钮字体颜色
    UIColor *titleColor = self.navTitleColor?:self.navigationController.navigationBar.tintColor;
    [backButton setTitleColor:titleColor forState:UIControlStateNormal];
    [backButton setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    //
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font = self.navButtonTitleFont?:(self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName]?:[UIFont systemFontOfSize:16]);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);     // 图片和字体靠近一点
    
    [backButton addTarget:self action:@selector(navigationItemHandleBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    //_navCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(doneButtonClicked:)];
    _navBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    return _navBackBarButtonItem;
}
// 导航栏 [关闭] 按钮
- (UIBarButtonItem *)navCloseBarButtonItem{
    if (_navCloseBarButtonItem) return _navCloseBarButtonItem;
    if (self.navigationItem.rightBarButtonItem == _doneItem && self.navigationItem.rightBarButtonItem != nil) {
        UIButton *closeButton = [[UIButton alloc] init];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        closeButton.titleLabel.font = self.navButtonTitleFont?:(self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName]?:[UIFont systemFontOfSize:16]);
        UIColor *titleColor = self.navTitleColor?:self.navigationController.navigationBar.tintColor;
        [closeButton setTitleColor:titleColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton sizeToFit];
        //_navCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(doneButtonClicked:)];
        _navCloseBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    } else {
        UIButton *closeButton = [[UIButton alloc] init];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        closeButton.titleLabel.font = self.navButtonTitleFont?:(self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName]?:[UIFont systemFontOfSize:16]);
        UIColor *titleColor = self.navTitleColor?:self.navigationController.navigationBar.tintColor;
        [closeButton setTitleColor:titleColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(navigationIemHandleClose:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton sizeToFit];
        //_navCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(navigationIemHandleClose:)];
        _navCloseBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    }
    return _navCloseBarButtonItem;
}
// 导航栏 [菜单] 按钮
- (UIBarButtonItem *)navMenuBarButtonItem {
    if (_navMenuBarButtonItem) return _navMenuBarButtonItem;
    
    UIImage *menuItemImage = [[UIImage imageNamed:@"vhl_nav_menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (self.navTitleColor) {
        UIGraphicsBeginImageContextWithOptions(menuItemImage.size, NO, menuItemImage.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, menuItemImage.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGRect rect = CGRectMake(0, 0, menuItemImage.size.width, menuItemImage.size.height);
        CGContextClipToMask(context, rect, menuItemImage.CGImage);
        [self.navTitleColor setFill];
        CGContextFillRect(context, rect);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        menuItemImage = newImage?:menuItemImage;
    }
    // 绘制高亮的背景
    UIGraphicsBeginImageContextWithOptions(menuItemImage.size, NO, menuItemImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, menuItemImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, menuItemImage.size.width, menuItemImage.size.height);
    CGContextClipToMask(context, rect, menuItemImage.CGImage);
    if (self.navTitleColor) {
        [[self.navTitleColor colorWithAlphaComponent:0.5] setFill];
    } else {
        [[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] setFill];
    }
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *menuItemHlImage = newImage?:[[UIImage imageNamed:@"vhl_nav_menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // -------------------------------------------------------------------------
    
    UIButton *menuButton = [[UIButton alloc] init];
    // 按钮图片
    [menuButton setImage:menuItemImage forState:UIControlStateNormal];
    [menuButton setImage:menuItemHlImage forState:UIControlStateHighlighted];
    
    [menuButton addTarget:self action:@selector(navigationMenuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [menuButton sizeToFit];
    _navMenuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    return _navMenuBarButtonItem;
}
//
- (void)setupSubviews {
    id topLayoutGuide    = self.topLayoutGuide;
    id bottomLayoutGuide = self.bottomLayoutGuide;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    // webview
    [self.view addSubview:self.webview];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView, topLayoutGuide, bottomLayoutGuide)]];
    
    //  bg lable
    UIView *contentView = _webView.scrollView;//.subviews.lastObject;
    [contentView addSubview:self.backgroundLabel];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_backgroundLabel(<=width)]" options:0 metrics:@{@"width":@([UIScreen mainScreen].bounds.size.width)} views:NSDictionaryOfVariableBindings(_backgroundLabel)]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-20]];
    
#endif
    
    self.progressView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 2);
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    // - ** JS 交互框架 ** -
    [WKWebViewJavascriptBridge enableLogging];
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];

    // 处理JS相关操作，监听以及注册事件
    self.vhlJSBridgeHandle = [[VHLWebViewJSBridgeHandle alloc] initWithVC:self jsBridge:_bridge];
    
    [self.vhlJSBridgeHandle jsSystemHanlde];
    [self.vhlJSBridgeHandle jsCustomHandle];
}
#pragma mark - Helper ------------------------------------------------------------------------------------------------------
// 修改导航栏按钮样式
- (void)updateNavigationItems {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -10;
    
    if (self.webview.canGoBack) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.navBackBarButtonItem,spaceButtonItem,self.navCloseBarButtonItem] animated:NO];
        } else {
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.navBackBarButtonItem,spaceButtonItem,self.navCloseBarButtonItem] animated:NO];
        }
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        // [self.navigationItem setLeftBarButtonItems:nil animated:NO];
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.navBackBarButtonItem] animated:NO];
    }
    if (!_hideNavMenuBarButton) {
        self.navigationItem.rightBarButtonItems = @[self.navMenuBarButtonItem];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    // 解决自定义 backBarButtonItem 后侧滑手势不可使用问题
    //self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
}
// 修改进度条
- (void)updateFrameOfProgressView {
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView.frame = barFrame;
}
- (void)updatingProgress:(NSTimer *)sender {
    if (!_loading) {
        if (_progressView.progress >= 1.0) {
            [_updating invalidate];
        }
        else {
            [_progressView setProgress:_progressView.progress + 0.05 animated:YES];
        }
    }
    else {
        [_progressView setProgress:_progressView.progress + 0.05 animated:YES];
        if (_progressView.progress >= 0.9) {
            _progressView.progress = 0.9;
        }
    }
}

- (void)hookWebContentCommitPreviewHandler {
    // Find the `WKContentView` in the webview.
    __weak typeof(self) wself = self;
    for (UIView *_view in _webView.scrollView.subviews) {
        if ([_view isKindOfClass:NSClassFromString(@"WKContentView")]) {
            id _previewItemController = object_getIvar(_view, class_getInstanceVariable([_view class], "_previewItemController"));
            Class _class = [_previewItemController class];
            SEL _performCustomCommitSelector = NSSelectorFromString(@"previewInteractionController:interactionProgress:forRevealAtLocation:inSourceView:containerView:");
            [_previewItemController aspect_hookSelector:_performCustomCommitSelector withOptions:AspectPositionAfter usingBlock:^() {
                UIViewController *pred = [_previewItemController valueForKeyPath:@"presentedViewController"];
                [pred aspect_hookSelector:NSSelectorFromString(@"_addRemoteView") withOptions:AspectPositionAfter usingBlock:^() {
                    UIViewController *_remoteViewController = object_getIvar(pred, class_getInstanceVariable([pred class], "_remoteViewController"));
                    
                    [_remoteViewController aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^() {
                        _remoteViewController.view.tintColor = wself.navigationController.navigationBar.tintColor;
                    } error:NULL];
                } error:NULL];
                
                NSArray *ddActions = [pred valueForKeyPath:@"ddActions"];
                id openURLAction = [ddActions firstObject];
                
                [openURLAction aspect_hookSelector:NSSelectorFromString(@"perform") withOptions:AspectPositionInstead usingBlock:^ () {
                    NSURL *_url = object_getIvar(openURLAction, class_getInstanceVariable([openURLAction class], "_url"));
                    [wself loadURL:_url];
                } error:NULL];
                
                id _lookupItem = object_getIvar(_previewItemController, class_getInstanceVariable([_class class], "_lookupItem"));
                [_lookupItem aspect_hookSelector:NSSelectorFromString(@"commit") withOptions:AspectPositionInstead usingBlock:^() {
                    NSURL *_url = object_getIvar(_lookupItem, class_getInstanceVariable([_lookupItem class], "_url"));
                    [wself loadURL:_url];
                } error:NULL];
                [_lookupItem aspect_hookSelector:NSSelectorFromString(@"commitWithTransitionForPreviewViewController:inViewController:completion:") withOptions:AspectPositionInstead usingBlock:^() {
                    NSURL *_url = object_getIvar(_lookupItem, class_getInstanceVariable([_lookupItem class], "_url"));
                    [wself loadURL:_url];
                } error:NULL];
                /*
                 UIWindow
                 -UITransitionView
                 --UIVisualEffectView
                 ---_UIVisualEffectContentView
                 ----UIView
                 -----_UIPreviewActionSheetView
                 */
                /*
                 for (UIView * transitionView in [UIApplication sharedApplication].keyWindow.subviews) {
                 if ([transitionView isMemberOfClass:NSClassFromString(@"UITransitionView")]) {
                 transitionView.tintColor = wself.navigationController.navigationBar.tintColor;
                 for (UIView *__view in transitionView.subviews) {
                 if ([__view isMemberOfClass:NSClassFromString(@"UIVisualEffectView")]) {
                 for (UIView *___view in __view.subviews) {
                 if ([___view isMemberOfClass:NSClassFromString(@"_UIVisualEffectContentView")]) {
                 for (UIView *____view in ___view.subviews) {
                 if ([____view isMemberOfClass:NSClassFromString(@"UIView")]) {
                 __weak typeof(____view) w____view = ____view;
                 [____view aspect_hookSelector:@selector(addSubview:) withOptions:AspectPositionAfter usingBlock:^() {
                 for (UIView *actionSheet in w____view.subviews) {
                 if ([actionSheet isMemberOfClass:NSClassFromString(@"_UIPreviewActionSheetView")]) {
                 break;
                 }
                 }
                 } error:NULL];
                 }
                 }break;
                 }
                 }break;
                 }
                 }break;
                 }
                 }
                 */
            } error:NULL];
            break;
        }
    }
}
/* ** 系统相关事件 ** */
- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {          // 摇一摇
        [[VHLWebViewRouteHandle shareInstance] handlePath:[NSURL URLWithString:@"sysShake://"] vc:self webview:self.webView];
        [self.vhlJSBridgeHandle jsCallback:@{@"type": @"sysShake"}];
    }
}
@end

