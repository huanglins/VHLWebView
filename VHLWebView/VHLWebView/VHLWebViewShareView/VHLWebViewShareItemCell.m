//
//  VHLWebViewShareItemCell.m
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewShareItemCell.h"
#import "VHLWebViewShareViewDefine.h"

@interface VHLWebViewShareItemCell()

@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UITextView *titleTxt;

@end

@implementation VHLWebViewShareItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    [self addSubview:self.iconButton];
    [self addSubview:self.titleTxt];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topPadding = 15.0f;
    CGFloat iconView2TitleH = 10.0f;
    CGFloat cellWidth = self.frame.size.width;
    CGFloat titleInset = 4;
    
    // 图标
    CGFloat iconViewX = VHL_ITEM_CELL_PADDING / 2;
    CGFloat iconViewY = topPadding;
    CGFloat iconViewW = cellWidth - VHL_ITEM_CELL_PADDING;
    CGFloat iconViewH = cellWidth - VHL_ITEM_CELL_PADDING;
    self.iconButton.frame = CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH);
    
    // 标题
    CGFloat titleViewX = -titleInset;
    CGFloat titleViewY = topPadding + iconViewH + iconView2TitleH;
    CGFloat titleViewW = cellWidth + 2 * titleInset;
    CGFloat titleViewH = 30.0f;
    self.titleTxt.frame = CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH);
}
#pragma mark - Actions
- (void)iconClick {
    if (self.item.selectionHandler) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VHL_HIDEN_NOTIFICATION object:nil];
        // 弹出层隐藏动画过渡，让效果自然些
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.item.selectionHandler();
        });
    } else {
        // 忽略警告
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未处理响应事件" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        #pragma clang diagnostic pop
    }
}
#pragma mark - setter
- (void)setItem:(VHLWebViewShareItem *)item{
    _item = item;
    
    [self.iconButton setImage:[UIImage imageNamed:item.icon] forState:UIControlStateNormal];
    self.titleTxt.text = item.title;
}
#pragma mark - getter
- (UIButton *)iconButton {
    if (!_iconButton) {
        _iconButton = [[UIButton alloc] init];
        [_iconButton addTarget:self action:@selector(iconClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconButton;
}
- (UITextView *)titleTxt {
    if (!_titleTxt) {
        _titleTxt = [[UITextView alloc] init];
        _titleTxt.textColor = [UIColor darkGrayColor];
        _titleTxt.font = [UIFont systemFontOfSize:11.0f];
        _titleTxt.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
        _titleTxt.backgroundColor = nil;
        _titleTxt.textAlignment = NSTextAlignmentCenter;
        _titleTxt.userInteractionEnabled = NO;
    }
    return _titleTxt;
}
@end
