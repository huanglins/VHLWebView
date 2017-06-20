//
//  TowViewController.m
//  VHLWebView
//
//  Created by vincent on 2017/5/27.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "TowViewController.h"
//
//#import "UINavigationController+JZExtension.h"
@interface TowViewController ()

@property (nonatomic, strong) UIButton *navBackButton;

@end

@implementation TowViewController

- (instancetype)init {
    if (self = [super init]) {
        //self.hidesNavigationBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 统一定义导航栏返回按钮
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -12;
    self.navigationItem.leftBarButtonItems = @[spaceButtonItem,self.sBackBarButtonItem];
    
    // ---------------------------------------------------------------------------------
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    NSString *post_data = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_data" ofType:nil]] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",post_data);
    
    NSString *urlString = @"http://183.63.131.106:40013/extService/ghbExtService.do";
    // urlString = @"http://192.168.100.96:8080/nweb/api3.html";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    NSString *postString = [NSString stringWithFormat:@"RequestData=%@&transCode=%@",post_data, @"OGW00090"];
    postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSData *data = [postString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    //[webView loadRequest:request];
    
    NSString *HTMLString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vhlwebhtml.bundle/post" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    
    [webView loadHTMLString:HTMLString baseURL:baseURL];
}
- (UIBarButtonItem *)sBackBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(navigationItemHandleBack)];
}
- (UIBarButtonItem *)backBarButtonItem {
    UIColor *itemColor = [UIColor blueColor];
    UIImage* backItemImage = [[UIImage imageNamed:@"vhl_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, backItemImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
    CGContextClipToMask(context, rect, backItemImage.CGImage);
    [itemColor setFill];             // **
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    backItemImage = newImage?:backItemImage;
    
    // 绘制高亮的背景
    UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
    CGContextRef navContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(navContext, 0, backItemImage.size.height);
    CGContextScaleCTM(navContext, 1.0, -1.0);
    CGContextSetBlendMode(navContext, kCGBlendModeNormal);
    CGRect navRect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
    CGContextClipToMask(navContext, navRect, backItemImage.CGImage);
    [[itemColor colorWithAlphaComponent:0.5] setFill];
    
    CGContextFillRect(navContext, navRect);
    UIImage *hlNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* backItemHlImage = hlNewImage?:[[UIImage imageNamed:@"vhl_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // -----------------------------------------------------------
    
    self.navBackButton = [[UIButton alloc] init];
    // 按钮图片
    [self.navBackButton setImage:backItemImage forState:UIControlStateNormal];
    [self.navBackButton setImage:backItemHlImage forState:UIControlStateHighlighted];
    // 按钮字体颜色
    [self.navBackButton setTitleColor:itemColor forState:UIControlStateNormal];
    [self.navBackButton setTitleColor:[itemColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    //
    [self.navBackButton setTitle:@"返回" forState:UIControlStateNormal];
    self.navBackButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.navBackButton.titleEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);     // 图片和字体靠近一点
    
    [self.navBackButton addTarget:self action:@selector(navigationItemHandleBack) forControlEvents:UIControlEventTouchUpInside];
    [self.navBackButton sizeToFit];
    //_navCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(doneButtonClicked:)];
    return [[UIBarButtonItem alloc] initWithCustomView:self.navBackButton];
}

- (void)navigationItemHandleBack {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
