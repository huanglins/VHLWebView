//
//  VHLWebViewNSURLProtocol.h
//  VHLWebView
//
//  Created by vincent on 2017/6/28.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLProtocol+WKWebView.h"

@interface VHLWebViewNSURLProtocol : NSURLProtocol

// 添加需要过滤的请求前缀
+ (NSSet *)filterURLPres;
+ (void)setFilterURLPres:(NSSet *)filterURLPres;

/** 清除Cache*/
+ (void)clearCache;

@end

/*
    不建议使用了。POST 会有大问题。
 */
