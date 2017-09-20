//
//  VHLWebViewChangeFontView.m
//  VHLWebView
//
//  Created by vincent on 16/8/30.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewChangeFontView.h"
#import "VHLWebViewChangeFontSliderView.h"

#define VHL_SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define VHL_SCREEN_HEIGTH           [UIScreen mainScreen].bounds.size.height

#define VHL_SPACE_HEIGHT            144.0
#define VHL_SPACE_HEIGHT_M          100.0      // 横屏的高度，要矮一些
#define VHL_ANIMATE_DURATION        0.3        // 隐藏显示动画时间
#define VHL_DIM_BACKGROUND_ALPHA    0.22       // 半透明背景的 alpha 值

@interface VHLWebViewChangeFontView() {
    CGFloat spaceHeight;
}

@property (nonatomic, strong) UIView *dimBackgroundView;        /**< 半透明黑色背景 */
@property (nonatomic, strong) UIToolbar *fontSizeBGView;        /**< 修改字体背景*/
@property (nonatomic, strong) VHLWebViewChangeFontSliderView *sliderView;

@property (nonatomic, strong) changeFontSizeBlock cfsBlock;

@end

@implementation VHLWebViewChangeFontView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    spaceHeight = VHL_SPACE_HEIGHT;
    self.frame = CGRectMake(0, 0, VHL_SCREEN_WIDTH, VHL_SCREEN_HEIGTH);
    
    // 添加屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ahandleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)layoutSubviews {
    self.frame = CGRectMake(0, 0, VHL_SCREEN_WIDTH, VHL_SCREEN_HEIGTH);
    self.dimBackgroundView.frame = self.bounds;
    
    CGRect frame = CGRectMake(0, VHL_SCREEN_HEIGTH - spaceHeight, VHL_SCREEN_WIDTH, spaceHeight);
    self.fontSizeBGView.frame = frame;
    
    self.sliderView.frame = self.fontSizeBGView.bounds;    
    [self.sliderView setNeedsLayout];
}
#pragma mark - getter
- (UIView *)dimBackgroundView {
    if (!_dimBackgroundView) {
        _dimBackgroundView = [[UIView alloc] init];
        _dimBackgroundView.frame = CGRectMake(0, 0, VHL_SCREEN_WIDTH, VHL_SCREEN_HEIGTH);
        _dimBackgroundView.userInteractionEnabled = YES;
        _dimBackgroundView.backgroundColor = [UIColor blackColor];
        _dimBackgroundView.alpha = 0.0;
        
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_dimBackgroundView addGestureRecognizer:tap];
    }
    return _dimBackgroundView;
}
- (UIToolbar *)fontSizeBGView{
    if (!_fontSizeBGView) {
        _fontSizeBGView = [[UIToolbar alloc] init];
        _fontSizeBGView.frame = CGRectMake(0, VHL_SCREEN_HEIGTH, VHL_SCREEN_WIDTH, VHL_SPACE_HEIGHT);
        _fontSizeBGView.clipsToBounds = YES;
    }
    return _fontSizeBGView;
}
- (VHLWebViewChangeFontSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[VHLWebViewChangeFontSliderView alloc] initWithFrame:CGRectMake(0, 0, MIN(400, VHL_SCREEN_WIDTH), VHL_SPACE_HEIGHT)];
        
        __weak typeof(self) weakSelf = self;
        _sliderView.sliderChangeBlock = ^(float sliderValue) {
            [weakSelf blockChange:sliderValue];
        };
    }
    return _sliderView;
}
- (void)blockChange:(float)sliderValue {
    _cfsBlock(sliderValue);
}
#pragma mark - private method
- (void)addTokeyWindow {
    if (!self.superview) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self];
        
        [self addSubview:self.dimBackgroundView];
        [self addSubview:self.fontSizeBGView];
        
        /** 适配iOS11 */
        if (@available(iOS 11.0, *)) {
            UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:self.sliderView];
            [self.fontSizeBGView setItems:@[barItem]];
        } else {
            [self.fontSizeBGView addSubview:self.sliderView];
        }
    }
}
- (void)removeFromKeyWindow {
    if (self.superview) {
        [self removeFromSuperview];
    }
}
- (void)showAnimationWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:VHL_ANIMATE_DURATION animations:^{
        self.dimBackgroundView.alpha = VHL_DIM_BACKGROUND_ALPHA;
        
        CGRect frame = self.fontSizeBGView.frame;
        frame.origin.y = VHL_SCREEN_HEIGTH - VHL_SPACE_HEIGHT;
        self.fontSizeBGView.frame = frame;
    } completion:completion];
}
- (void)hideAnimationWithComplection:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:VHL_ANIMATE_DURATION animations:^{
        self.dimBackgroundView.alpha = 0.0;
        
        CGRect frame = self.fontSizeBGView.frame;
        frame.origin.y = VHL_SCREEN_HEIGTH;
        self.fontSizeBGView.frame = frame;
    } completion:completion];
}
#pragma mark - public method
- (void)setSliderValue:(int)sliderValue{
    [self.sliderView setSliderValue:sliderValue];
}
- (void)show {
    [self addTokeyWindow];
    [self showAnimationWithCompletion:nil];
}
- (void)hide {
    [self hideAnimationWithComplection:^(BOOL finished) {
        [self removeFromKeyWindow];
    }];
}
- (void)changeSize:(changeFontSizeBlock)fsBlock{
    _cfsBlock = fsBlock;
}
#pragma mark - 
- (void)ahandleDeviceOrientationDidChange:(NSNotification *)noti
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            spaceHeight = VHL_SPACE_HEIGHT_M;
            break;
        case UIDeviceOrientationLandscapeRight:
            spaceHeight = VHL_SPACE_HEIGHT_M;
            break;
        case UIDeviceOrientationPortrait:
            spaceHeight = VHL_SPACE_HEIGHT;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            spaceHeight = VHL_SPACE_HEIGHT;
            break;
        default:
            break;
    }
    [self setNeedsLayout];
}

@end
