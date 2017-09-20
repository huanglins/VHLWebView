//
//  VHLNavigation.h
//  VHLWebView
//
//  Created by vincent on 2017/8/23.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// -----------------------------------------------------------------------------
@interface UINavigationBar (VHLNavigation)

/** 设置当前 NavigationBar 背景透明度*/
- (void)vhl_setBackgroundAlpha:(CGFloat)alpha;
/** 设置导航栏所有 barButtonItem 的透明度*/
- (void)vhl_setBarButtonItemsAlpha:(CGFloat)alpha hasSystemBackIndicator:(BOOL)hasSystemBackIndicator;

/** 设置当前 NavigationBar 垂直方向上的平移距离*/
- (void)vhl_setTranslationY:(CGFloat)translationY;
/** 获取当前导航栏垂直方向上偏移了多少*/
- (CGFloat)vhl_getTranslationY;

@end

// -----------------------------------------------------------------------------
typedef NS_ENUM(NSInteger, VHLNavigationSwitchStyle) {
    VHLNavigationSwitchStyleTransition = 0,        // 颜色过渡的方式，支付宝个人中心到余额宝切换效果
    VHLNavigationSwitchStyleFakeNavBar = 1,        // 两种不同颜色导航栏，类似微信红包
};

/** UIViewController 导航栏扩展 */
@interface UIViewController (VHLNavigation)

/** 设置当前导航栏侧滑过度效果*/
- (void)vhl_setNavigationSwitchStyle:(VHLNavigationSwitchStyle)style;
- (VHLNavigationSwitchStyle)vhl_navigationSwitchStyle;

/** 设置当前导航栏是否隐藏，设置隐藏后不会有侧滑效果，想要有侧滑效果不要隐藏导航栏，而是设置导航栏透明度为 0.0f*/
- (void)vhl_setNavBarHidden:(BOOL)hidden;
- (BOOL)vhl_navBarHidden;

/** 设置当前导航栏的背景图片，即使当前导航栏过渡样式为颜色渐变也为执行微信样式过渡*/
- (void)vhl_setNavBarBackgroundImage:(UIImage *)image;
- (UIImage *)vhl_navBarBackgroundImage;

/** 设置当前导航栏的透明度*/
- (void)vhl_setNavBarBackgroundAlpha:(CGFloat)alpha;
- (CGFloat)vhl_navBarBackgroundAlpha;

/** 设置当前导航栏 barTintColor(导航栏背景颜色)*/
- (void)vhl_setNavBarBarTintColor:(UIColor *)color;
- (UIColor *)vhl_navBarBarTintColor;

/** 设置当前导航栏 TintColor(导航栏按钮等颜色)*/
- (void)vhl_setNavBarTintColor:(UIColor *)color;
- (UIColor *)vhl_navBarTintColor;

/** 设置当前导航栏 titleColor(标题颜色)*/
- (void)vhl_setNavBarTitleColor:(UIColor *)color;
- (UIColor *)vhl_navBarTitleColor;

/** 设置当前导航栏 shadowImage(底部分割线)是否隐藏*/
- (void)vhl_setNavBarShadowImageHidden:(BOOL)hidden;
- (BOOL)vhl_navBarShadowImageHidden;

/** 设置当前状态栏样式 白色/黑色，也可以直接重写 preferredStatusBarStyle */
- (void)vhl_setStatusBarStyle:(UIStatusBarStyle)style;
- (UIStatusBarStyle)vhl_statusBarStyle;

@end


/*
    associated 关联的
 */

/*
    http://www.jianshu.com/p/e3ca1b7b6cec
    https://github.com/wangrui460/WRNavigationBar
    https://github.com/CrazyGitter/HansNavController
 */
