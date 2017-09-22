//
//  VHLShareItem.m
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewShareItem.h"

@implementation VHLWebViewShareItem

+ (instancetype)itemWithTitle:(NSString *)title
                         icon:(NSString *)icon
                      handler:(void (^)(void))handler
{
    VHLWebViewShareItem *item = [[VHLWebViewShareItem alloc] init];
    item.title = title;
    item.icon  = icon;
    item.selectionHandler = handler;
    return item;
}

@end
