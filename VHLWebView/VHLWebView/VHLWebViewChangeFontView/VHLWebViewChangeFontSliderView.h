//
//  VHLWebViewChangeFontSliderView.h
//  VHLWebView
//
//  Created by vincent on 16/9/1.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHLWebViewChangeFontSliderView : UIView

@property (nonatomic, copy) void(^sliderChangeBlock)(float sliderValue);

/**
 *  修改slider值(1-5)
 */
- (void)setSliderValue:(int)value;

@end
