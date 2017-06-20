//
//  VHLWebViewChangeFontView.h
//  VHLWebView
//
//  Created by vincent on 16/8/30.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^changeFontSizeBlock)(CGFloat stepValue);

@interface VHLWebViewChangeFontView : UIView

/**
 *  (1-5)
 */
- (void)setSliderValue:(int)sliderValue;
/**
 *  显示/隐藏
 */
- (void)show;
- (void)hide;

- (void)changeSize:(changeFontSizeBlock)fsBlock;

@end
