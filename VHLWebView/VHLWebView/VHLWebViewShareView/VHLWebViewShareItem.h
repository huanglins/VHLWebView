//
//  VHLShareItem.h
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHLWebViewShareItem : NSObject

@property (nonatomic, copy) NSString *icon;             /**< 图标名称 */
@property (nonatomic, copy) NSString *title;            /**< 标题 */
@property (nonatomic, copy) void (^selectionHandler)(void); /**< 点击后的事件处理 */

+ (instancetype)itemWithTitle:(NSString *)title
                         icon:(NSString *)icon
                      handler:(void (^)(void))handler;

@end
