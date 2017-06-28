//
//  NSURLProtocol+WKWebView.h
//  VHLWebView
//
//  Created by vincent on 2017/6/28.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    扩展为了使 WKWebView 支持 NSURLProtocol
 */
@interface NSURLProtocol (WKWebView)

+ (void)wk_registerScheme:(NSString *)scheme;

+ (void)wk_unregisterScheme:(NSString *)scheme;

@end

/*
    学习：
    https://github.com/LiuShuoyu/HybirdWKWebVIew
 */
