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

/** 清除Cache*/
+ (void)clearCache;

@end
