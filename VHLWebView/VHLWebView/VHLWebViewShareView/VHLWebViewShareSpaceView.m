//
//  VHLWebViewSpaceView.m
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewShareSpaceView.h"
#import "VHLWebViewShareViewDefine.h"
#import "VHLWebViewShareSpaceCell.h"

#define VHL_TITLE_HEIGHT    30.0f
#define VHL_TITLE_PADDING   20.0f

@interface VHLWebViewShareSpaceView()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation VHLWebViewShareSpaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    [self addSubview:self.titleLabel];
    [self addSubview:self.tableView];
    [self addSubview:self.cancelButton];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.frame;
    frame.size.height = [self shareSpaceHeight];
    frame.size.width = VHL_SCREEN_WIDTH;
    self.frame = frame;
    
    // 标题
    self.titleLabel.frame = CGRectMake(VHL_TITLE_PADDING, 0, VHL_SCREEN_WIDTH - 2 * VHL_TITLE_PADDING, VHL_TITLE_HEIGHT);
    // 取消按钮
    self.cancelButton.frame = CGRectMake(0, self.frame.size.height - VHL_CANCEL_BUTTON_HEIGHT, VHL_SCREEN_WIDTH, VHL_CANCEL_BUTTON_HEIGHT);
    // table view
    self.tableView.frame = CGRectMake(0, self.titleHeight, VHL_SCREEN_WIDTH, self.dataArray.count *VHL_ITEM_CELL_HEIGHT);
}
#pragma mark - Action
- (void)cancelButtonClick {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemArray = self.dataArray[indexPath.row];
    
    VHLWebViewShareSpaceCell *cell = [VHLWebViewShareSpaceCell cellWithTableView:tableView];
    cell.itemArray = itemArray;
    
    return cell;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.text = @"分享";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _titleLabel;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = VHL_ITEM_CELL_HEIGHT;
        _tableView.bounces = NO;
        _tableView.backgroundColor = nil;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.9642 green:0.9676 blue:0.9778 alpha:1.0]] forState:UIControlStateHighlighted];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (CGFloat)shareSpaceHeight {
    // -1 用来让取消 button 挡住下面cell的seperator(分割线)
    return self.initialHeight + self.dataArray.count * VHL_ITEM_CELL_HEIGHT - 1;
}
- (CGFloat)initialHeight {
    return VHL_CANCEL_BUTTON_HEIGHT + self.titleHeight;
}
- (CGFloat)titleHeight {
    return self.titleLabel.text.length ? VHL_TITLE_HEIGHT : 0;
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
