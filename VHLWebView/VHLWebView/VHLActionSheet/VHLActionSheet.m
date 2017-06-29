//
//  HJCActionSheet.m
//  wash
//
//  Created by weixikeji on 15/5/11.
//
//

#import "VHLActionSheet.h"

// 每个按钮的高度
#define BtnHeight 50
// 取消按钮上面的间隔高度
#define Margin 8

#define HLCColor(r, g, b, a) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
// 背景色
#define GlobelBgColor HLCColor(237, 240, 242, 0.6)
// 分割线颜色
#define GlobelSeparatorColor HLCColor(226, 226, 226, 1.0)
// 普通状态下的图片
#define normalImage [self createImageWithColor:[UIColor whiteColor]]    //HJCColor(255, 255, 255)
// 高亮状态下的图片
#define highImage [self createImageWithColor:[UIColor colorWithRed:0.9642 green:0.9676 blue:0.9778 alpha:1.0]]      //HJCColor(242, 242, 242)

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//
#define VHL_isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
// 字体
#define HeitiLight(f) [UIFont fontWithName:@"STHeitiSC-Light" size:f]
#define SystemFont(f) [UIFont systemFontOfSize:f]

@interface VHLActionSheet ()
{
    int _tag;
}

@property (nonatomic, weak) VHLActionSheet *actionSheet;
@property (nonatomic, weak) UIView *sheetView;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) SelectedButtonIndexBlock sBlock;

@property (nonatomic, assign) CGFloat topTitleHeight;

@end

@implementation VHLActionSheet

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  创建对象方法
 */
- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<VHLActionSheetDelegate>)delegate
                  cancelTitle:(NSString *)cancelTitle
       destructiveButtonTitle:(NSString *)destructiveTitle
                  otherTitles:(NSString*)otherTitles,... NS_REQUIRES_NIL_TERMINATION
{
    VHLActionSheet *actionSheet = [self init];
    self.actionSheet = actionSheet;
    
    actionSheet.delegate = delegate;
    
    // 黑色遮盖
    actionSheet.frame = [UIScreen mainScreen].bounds;
    actionSheet.backgroundColor = [UIColor blackColor];

    [[UIApplication sharedApplication].keyWindow addSubview:actionSheet];

    actionSheet.alpha = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [actionSheet addGestureRecognizer:tap];
    
    // sheet 容器视图
    UIView *sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    sheetView.backgroundColor = GlobelBgColor;
    sheetView.alpha = 0.9;
    [[UIApplication sharedApplication].keyWindow addSubview:sheetView];
    self.sheetView = sheetView;
    sheetView.hidden = YES;

    // 1.如果有标题
    if(title){
        [self setupTopTitle:title];
    }
    // 2.如果有第一个醒目的选项
    _tag = 1;
    if(destructiveTitle)
    {
        [self setupBtnWithTitle:destructiveTitle titleColor:[UIColor colorWithRed:0.9751 green:0.2731 blue:0.3462 alpha:1.0]];
    }
    // 3.其他按钮，动态数量【*】
    NSString* curStr;
    va_list list;
    if(otherTitles)
    {
        [self setupBtnWithTitle:otherTitles titleColor:nil];
        
        va_start(list, otherTitles);
        while ((curStr = va_arg(list, NSString*))) {
            [self setupBtnWithTitle:curStr titleColor:nil];
        }
        va_end(list);
    }
    // 重新计算 sheetView 的高度
    CGRect sheetViewF = sheetView.frame;
    sheetViewF.size.height = BtnHeight * _tag + Margin + _topTitleHeight;
    sheetView.frame = sheetViewF;
    
    // 4.取消按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, sheetView.frame.size.height - BtnHeight, self.sheetView.bounds.size.width, BtnHeight)];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = SystemFont(18); // HeitiLight(17);
    btn.tag = 0;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    // iPad 居中
    if(VHL_isPad){
        sheetView.bounds = CGRectMake(0, 0, MIN(ScreenWidth * 0.68, 600), sheetView.frame.size.height);
        sheetView.layer.cornerRadius = 6;
        sheetView.layer.masksToBounds = YES;
        sheetView.center = CGPointMake(ScreenWidth / 2, ScreenHeight / 2);
        
        for (UIView *subView in self.sheetView.subviews) {
            CGRect subViewFrame = subView.frame;
            subView.frame = CGRectMake(subViewFrame.origin.x, subView.frame.origin.y, self.sheetView.frame.size.width, subViewFrame.size.height);
        }
        self.titleLabel.center = self.titleView.center;
    }
    
    // 添加屏幕旋转的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    return actionSheet;
}
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    // actionSheet
    self.actionSheet.frame = [UIScreen mainScreen].bounds;
    // sheetview
    CGRect sheetViewFrame = self.sheetView.frame;
    self.sheetView.frame = CGRectMake(0, ScreenHeight - sheetViewFrame.size.height, ScreenWidth, sheetViewFrame.size.height);
    // iPad 居中
    if(VHL_isPad){
        self.sheetView.bounds = CGRectMake(0, 0, MIN(ScreenWidth * 0.68, 600), sheetViewFrame.size.height);
        self.sheetView.layer.cornerRadius = 6;
        self.sheetView.layer.masksToBounds = YES;
        self.sheetView.center = CGPointMake(ScreenWidth / 2, ScreenHeight / 2);
    }
    
    for (UIView *subView in self.sheetView.subviews) {
        CGRect subViewFrame = subView.frame;
        subView.frame = CGRectMake(subViewFrame.origin.x, subView.frame.origin.y, self.sheetView.frame.size.width, subViewFrame.size.height);
    }
    self.titleLabel.center = self.titleView.center;
}
#pragma mark --------------- 显示/隐藏 ---------------
/** 显示*/
- (void)show{
    self.sheetView.hidden = NO;

    if (VHL_isPad) {
        [UIView animateWithDuration:0.3 animations:^{
            self.actionSheet.alpha = 0.4;
            self.sheetView.alpha = 1.0;
        }];
    } else {
        CGRect sheetViewF = self.sheetView.frame;
        sheetViewF.origin.y = ScreenHeight;
        self.sheetView.frame = sheetViewF;
        
        CGRect newSheetViewF = self.sheetView.frame;
        newSheetViewF.origin.y = ScreenHeight - self.sheetView.frame.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.sheetView.frame = newSheetViewF;
            
            self.actionSheet.alpha = 0.4;
            self.sheetView.alpha = 1.0;
        }];
    }
}
/** 隐藏*/
- (void)hide
{
    if (VHL_isPad) {
        [UIView animateWithDuration:0.2 animations:^{
            self.sheetView.alpha = 0.0;
            self.actionSheet.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.sheetView removeFromSuperview];
            [self.actionSheet removeFromSuperview];
            //[self.rootWindow resignKeyWindow];
        }];
    } else {
        CGRect sheetViewF = self.sheetView.frame;
        sheetViewF.origin.y = ScreenHeight;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.sheetView.frame = sheetViewF;
            self.actionSheet.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.sheetView removeFromSuperview];
            [self.actionSheet removeFromSuperview];
            //[self.rootWindow resignKeyWindow];
        }];
    }
}
- (void)buttonIndex:(SelectedButtonIndexBlock)sBlock
{
    _sBlock = sBlock;
}
//------------------------------------------------------------------------------
- (void)setupTopTitle:(NSString *)title
{
    CGFloat svWidth = self.sheetView.bounds.size.width;
    if (VHL_isPad) {
        svWidth = MIN(ScreenWidth * 0.68, 600);
    }
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, svWidth, 60)];
    self.titleView.backgroundColor = [UIColor whiteColor];
    [self.sheetView addSubview:self.titleView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, svWidth - 20, 100)];
    self.titleLabel.numberOfLines = 4;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor colorWithRed:0.6 green:0.6039 blue:0.6078 alpha:1.0];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel sizeToFit];
    [self.titleView addSubview:self.titleLabel];
    
    CGRect topTRect = self.titleLabel.frame;
    topTRect.size.height = MAX(60, self.titleLabel.frame.size.height + 40);
    self.titleLabel.frame = topTRect;
    
    self.titleLabel.center = self.titleView.center;
    
    _topTitleHeight = topTRect.size.height;
}
- (void)setupBtnWithTitle:(NSString *)title titleColor:(UIColor *)tColor{
    CGFloat svWidth = self.sheetView.bounds.size.width;
    // 创建按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, BtnHeight * (_tag - 1) + _topTitleHeight, svWidth, BtnHeight)];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:tColor?:[UIColor colorWithRed:0.149 green:0.149 blue:0.1529 alpha:1.0] forState:UIControlStateNormal];
    btn.titleLabel.font = SystemFont(18);//HeitiLight(17);
    btn.tag = _tag;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    // 最上面画分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    line.backgroundColor = GlobelSeparatorColor;
    [btn addSubview:line];
    
    _tag ++;
}
//------------------------------------------------------------------------------

- (void)sheetBtnClick:(UIButton *)btn{
    if (btn.tag == 0) {
        [self hide];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self.actionSheet clickedButtonAtIndex:btn.tag];
        [self hide];
    }
    if(self.sBlock)
    {
        self.sBlock(btn.tag);
        [self hide];
    }
}
#pragma mark - Util - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - -
// 通过颜色创建图片
- (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
