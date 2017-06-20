//
//  VHLWebShareView.h
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHLWebViewShareItem.h"

@interface VHLWebViewShareView : UIView

/** 顶部标题Label，默认内容为"分享" */
@property (nonatomic, readonly) UILabel *titleLabel;
/** 底部取消Button，默认标题为"取消" */
@property (nonatomic, readonly) UIButton *cancelButton;

/**
 *  创建shareView
 *
 *  @param shareArray    分享item数组
 *  @param functionArray 功能item数组
 */
+ (instancetype)shareViewWithShareItems:(NSArray *)shareArray
                         funcationItems:(NSArray *)functionArray;
- (instancetype)initWithShareItems:(NSArray *)shareArray
                         funcationItems:(NSArray *)funcationArray;

/**
 *  创建具有n行的shareView
 *
 *  @param array (eg: @[shareArray, functionArray, otherItemsArray, ...])
 */
- (instancetype)initWithItemsArray:(NSArray *)array;

/**
 *  显示/隐藏
 */
- (void)show;
- (void)hide;

@end
