//
//  VHLWebViewSpaceView.h
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHLWebViewShareSpaceView : UIToolbar

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, copy) void (^cancelBlock)();

- (CGFloat)shareSpaceHeight;
- (CGFloat)initialHeight;

@end

/**
     iOS11 下 UIToolBar 上层会有一个 UIButtonBarStackView
     添加到 UIToolBar 上的UI会失效
 */
