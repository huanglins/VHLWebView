//
//  VHLWebShareView.m
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewShareView.h"
#import "VHLWebViewShareViewDefine.h"
#import "VHLWebViewShareSpaceView.h"

@interface VHLWebViewShareView()

@property (nonatomic, strong) UIView *dimBackgroundView;                /**< 半透明黑色背景 */
@property (nonatomic, strong) VHLWebViewShareSpaceView *shareSpaceView; /**< 分享面板*/

@end

@implementation VHLWebViewShareView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)shareViewWithShareItems:(NSArray *)shareArray funcationItems:(NSArray *)functionArray {
    VHLWebViewShareView *shareView = [[self alloc] initWithShareItems:shareArray funcationItems:functionArray];
    return shareView;
}
- (instancetype)initWithShareItems:(NSArray *)shareArray funcationItems:(NSArray *)funcationArray {
    NSMutableArray *itemsArrayM = [NSMutableArray array];
    if(shareArray.count) [itemsArrayM addObject:shareArray];
    if(funcationArray.count) [itemsArrayM addObject:funcationArray];
    
    return [self initWithItemsArray:itemsArrayM];
}
- (instancetype)initWithItemsArray:(NSArray *)array {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        [self.shareSpaceView.dataArray addObjectsFromArray:array];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    self.frame = CGRectMake(0, 0, VHL_SCREEN_WIDTH, VHL_SCREEN_HEIGTH);
    
    // 取消按钮点击监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide) name:VHL_HIDEN_NOTIFICATION object:nil];
    // 添加屏幕旋转的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}
- (void)layoutSubviews {
    self.frame = CGRectMake(0, 0, VHL_SCREEN_WIDTH, VHL_SCREEN_HEIGTH);
    self.dimBackgroundView.frame = self.bounds;
    
    CGRect frame = self.shareSpaceView.frame;
    frame.origin.y = VHL_SCREEN_HEIGTH - self.shareSpaceView.shareSpaceHeight;
    self.shareSpaceView.frame = frame;
    [self.shareSpaceView layoutSubviews];
}
#pragma mark - private method
- (void)addToKeyWindow {
    if (!self.superview) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self];
        
        [self addSubview:self.dimBackgroundView];
        [self addSubview:self.shareSpaceView];
    }
}
- (void)removeFromKeyWindow {
    if (self.superview) {
        [self removeFromSuperview];
    }
}
// 分享面板弹出动画
- (void)showAnimationWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:VHL_ANIMATE_DURATION animations:^{
        self.dimBackgroundView.alpha = VHL_DIM_BACKGROUND_ALPHA;
        
        CGRect frame = self.shareSpaceView.frame;
        frame.origin.y = VHL_SCREEN_HEIGTH - self.shareSpaceView.shareSpaceHeight;
        self.shareSpaceView.frame = frame;
    } completion:completion];
}
// 分享面板隐藏动画
- (void)hideAnimationWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:VHL_ANIMATE_DURATION animations:^{
        self.dimBackgroundView.alpha = 0;
        
        CGRect frame = self.shareSpaceView.frame;
        frame.origin.y = VHL_SCREEN_HEIGTH;
        self.shareSpaceView.frame = frame;
    } completion:completion];
}
#pragma mark - public method
- (void)show {
    [self addToKeyWindow];
    [self showAnimationWithCompletion:nil];
}
- (void)hide {
    [self hideAnimationWithCompletion:^(BOOL finished) {
        [self removeFromKeyWindow];
    }];
}
#pragma mark - getteer
- (VHLWebViewShareSpaceView *)shareSpaceView {
    if (!_shareSpaceView) {
        _shareSpaceView = [[VHLWebViewShareSpaceView alloc] init];
        _shareSpaceView.frame = CGRectMake(0, VHL_SCREEN_HEIGTH, VHL_SCREEN_WIDTH, _shareSpaceView.initialHeight);
        _shareSpaceView.clipsToBounds = YES;        // 去掉ToolBar顶部的黑线
        __weak typeof(self) weakSelf = self;
        _shareSpaceView.cancelBlock = ^{
            [weakSelf hide];
        };
    }
    return _shareSpaceView;
}
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
- (UILabel *)titleLabel {
    return self.shareSpaceView.titleLabel;
}
- (UIButton *)cancelButton {
    return self.shareSpaceView.cancelButton;
}
#pragma mark - 
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    [self setNeedsLayout];
}
@end
