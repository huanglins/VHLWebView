//
//  ViewController.m
//  VHLWebView
//
//  Created by vincent on 16/8/24.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "ViewController.h"
#import "TowViewController.h"
#import "VHLWebViewController.h"
//#import <UINavigationController+FDFullscreenPopGesture.h>
//#import "UINavigationController+JZExtension.h"
//#import <UINavigationController+JZExtension.h>
//#import <UIViewController+JZExtension.h>

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation     NS_AVAILABLE_IOS(6_0)
{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goWebView:(id)sender {
    NSString *urlString = @"http://183.63.131.106:40013/extService/ghbExtService.do";
    
    NSString *post_data = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_data" ofType:nil]] encoding:NSUTF8StringEncoding];
    NSString *trans_code = @"OGW00090";
//    post_data = [post_data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    trans_code = [trans_code stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"\n" withString:@"%5Cn"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"\t" withString:@"%5Ct"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    NSString *postString = [NSString stringWithFormat:@"\"RequestData\":\"%@\",\"transCode\":\"%@\"", post_data,trans_code];
//    postString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                        (CFStringRef)postString,
//                                                                                        NULL,
//                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
//                                                                                        kCFStringEncodingUTF8));
    //postString = [postString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    //postString = [postString stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
    //postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    NSData *data = [postString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
//    NSDictionary *pad = @{
//                          @"RequestData":post_data,
//                          @"transCode":trans_code
//                          };
    
    VHLWebViewController *webVC = [[VHLWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.105:8020/vapi/hybrid.html"]];
    //VHLWebViewController *webVC = [[VHLWebViewController alloc] init];
    //[webVC loadPostRequestURL:urlString postData:pad title:@"华兴银行开户"];
    //VHLWebViewController *webVC = [[VHLWebViewController alloc] initWithRequest:request];
    //webVC.hidesNavigationBarWhenPushed = YES;
    webVC.progressTintColor = [UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0];
    webVC.navTitleColor = [UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0];
    webVC.webScrollViewBGColor = [UIColor whiteColor];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)goVC:(id)sender {
    TowViewController *vc = [[TowViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
