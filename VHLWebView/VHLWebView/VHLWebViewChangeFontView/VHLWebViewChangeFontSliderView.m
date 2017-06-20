//
//  VHLWebViewChangeFontSliderView.m
//  VHLWebView
//
//  Created by vincent on 16/9/1.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewChangeFontSliderView.h"

@interface VHLWebViewChangeFontSliderView()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIView   *sliderBGView;

@end

@implementation VHLWebViewChangeFontSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    [self addSubview:self.sliderBGView];
    [self addSubview:self.slider];
    self.backgroundColor = [UIColor clearColor];
}
- (void)layoutSubviews {
    self.sliderBGView.center = CGPointMake(self.center.x, self.center.y + 2);
    self.slider.center = CGPointMake(self.center.x, self.center.y + 22);
}
#pragma mark - getter
- (UIView *)sliderBGView {
    if (!_sliderBGView) {
        _sliderBGView = [[UIView alloc] initWithFrame:CGRectMake(36, 0, self.bounds.size.width - 36 * 2, 56)];
        //_sliderBGView.backgroundColor = [UIColor grayColor];
        // 小a
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 4, 20, 20)];
        aLabel.textColor = [UIColor blackColor];
        aLabel.font = [UIFont systemFontOfSize:15];
        aLabel.text = @"A";
        [aLabel sizeToFit];
        [_sliderBGView addSubview:aLabel];
        // 标准
        UILabel *bLabel = [[UILabel alloc] initWithFrame:CGRectMake(_sliderBGView.frame.size.width / 5 + 2, 4, 20, 20)];
        bLabel.textColor = [UIColor colorWithRed:0.5294 green:0.5294 blue:0.5294 alpha:1.0];
        bLabel.font = [UIFont systemFontOfSize:16];
        bLabel.text = @"标准";
        [bLabel sizeToFit];
        [_sliderBGView addSubview:bLabel];
        // 大A
        UILabel *baLabel = [[UILabel alloc] initWithFrame:CGRectMake(_sliderBGView.frame.size.width - 14, 4, 16, 16)];
        baLabel.textColor = [UIColor blackColor];
        baLabel.font = [UIFont systemFontOfSize:20];
        baLabel.text = @"A";
        [baLabel sizeToFit];
        [_sliderBGView addSubview:baLabel];
        // 刻度线
        UIView *hLineView = [[UIView alloc] initWithFrame:CGRectMake(8, 48, _sliderBGView.frame.size.width - 16, 1)];
        hLineView.backgroundColor = [UIColor colorWithRed:0.5294 green:0.5294 blue:0.5294 alpha:1.0];
        [_sliderBGView addSubview:hLineView];
        for (int i = 0; i < 5; i ++) {
            UIView *vLineView = [[UIView alloc] initWithFrame:CGRectMake(8 + (self.bounds.size.width - 8 * 2) / 5 * i , 44, 1, 8)];
            vLineView.backgroundColor = [UIColor colorWithRed:0.5294 green:0.5294 blue:0.5294 alpha:1.0];
            [_sliderBGView addSubview:vLineView];
        }
    }
    return _sliderBGView;
}
- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(26, 0, self.bounds.size.width - 26 * 2, 20)];
        _slider.minimumValue = 1;
        _slider.maximumValue = 5;
        _slider.minimumTrackTintColor = [UIColor clearColor];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        
        // 添加滑动和点击事件
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSlider:)];
        [_slider addGestureRecognizer:tapSlider];
    }
    return _slider;
}
#pragma mark - 
- (void)sliderValueChanged:(UISlider *)slider {
    NSString *tempStr = [self numberFormat:slider.value];
    [slider setValue:tempStr.floatValue];
    // 回传
    _sliderChangeBlock(tempStr.floatValue);
}
- (void)tapSlider:(UITapGestureRecognizer *)sender {
    // 取得点击点
    CGPoint p = [sender locationInView:_slider];
    // 计算处于背景图的几分之几，并将之转换为滑块的值（1-5）
    float tempFloat = (p.x - 15) / _slider.frame.size.width * 5 + 1;
    if (tempFloat < _slider.minimumValue) {
        tempFloat = _slider.minimumValue;
    }
    if (tempFloat > _slider.maximumValue) {
        tempFloat = _slider.maximumValue;
    }
    NSString *tempStr = [self numberFormat:tempFloat];
    [_slider setValue:tempStr.floatValue];
    // 回传
    _sliderChangeBlock(tempStr.floatValue);
}
/**
 *  四舍五入
 *
 *  @param num 待转换数字
 *
 *  @return 转换后的数字
 */
- (NSString *)numberFormat:(float)num {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0"];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:num]];
}
#pragma mark - public method
/**
 *  修改slider值(1-5)
 */
- (void)setSliderValue:(int)value
{
    [_slider setValue:value];
}

@end
