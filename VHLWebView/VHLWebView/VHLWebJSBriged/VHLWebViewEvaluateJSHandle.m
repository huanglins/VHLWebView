//
//  VHLWebViewEvaluateJSHandle.m
//  PingLianBank
//
//  Created by vincent on 2017/6/21.
//  Copyright © 2017年 PingLianBank. All rights reserved.
//

#import "VHLWebViewEvaluateJSHandle.h"

@implementation VHLWebViewEvaluateJSHandle

static  NSString * const jsGetImages = @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
                                             var imgArray = new Array();\
                                             for(var i=0;i<objs.length;i++){\
                                                 imgArray.push(objs[i].src);\
                                             };\
                                             return imgArray;\
                                             };\
getImages();";

// 单例
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static VHLWebViewEvaluateJSHandle *evaluatejsHandle = nil;
    dispatch_once(&onceToken, ^{
        evaluatejsHandle = [[VHLWebViewEvaluateJSHandle alloc] init];
    });
    return evaluatejsHandle;
}

// 全局的JS执行
- (void)evaluateJSWebView:(WKWebView *)webview viewController:(UIViewController *)vc {
    NSString *host = webview.URL.host;
    // 1. 获取当前网页下所有图片链接的数组
    {
        [webview evaluateJavaScript:jsGetImages completionHandler:^(id imagesResult, NSError * _Nullable error) {
            //NSLog(@"%@ %@",imagesResult, [error description]);
        }];
    }
    // 2. 修改华兴银行网页颜色
    if ([@[@"183.63.131.106"] containsObject:host]){
        // document.getElementsByClassName('header_btn_left')[0].style.display = \"none\";
        // document.getElementsByClassName('ui-menu-header')[0].style.display = \"none\";
        [webview evaluateJavaScript:@"document.getElementsByClassName('ui-menu-header')[0].style.background = \"#2C4A7A\";document.getElementsByClassName('header_btn_left')[0].style.display = \"none\";" completionHandler:^(id _Nullable reslut, NSError * _Nullable error) {
            NSLog(@"%@ %@",reslut, [error description]);
        }];
    }
}

@end
