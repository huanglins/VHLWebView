//
//  VHLWebViewSpaceCell.m
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewShareSpaceCell.h"
#import "VHLWebViewShareViewDefine.h"
#import "VHLWebViewShareItemCell.h"
#import "VHLWebViewShareItem.h"

@interface VHLWebViewShareSpaceCell() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation VHLWebViewShareSpaceCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIdentifier = @"VHLWebViewShareSpaceCell";
    VHLWebViewShareSpaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[VHLWebViewShareSpaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    self.backgroundColor = nil;
    [self addSubview:self.collectionView];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VHLWebViewShareItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:vhl_share_item_cell_identifier forIndexPath:indexPath];
    
    VHLWebViewShareItem *item = self.itemArray[indexPath.item];
    NSAssert([item isKindOfClass:[VHLWebViewShareItem class]], @"数组元素必须为 VHLWebViewShareItem 对象");
    cell.item = item;
    
    return cell;
}
#pragma mark - setter
- (void)setItemArray:(NSArray *)itemArray {
    _itemArray = itemArray;
}
#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.alwaysBounceHorizontal = YES;           // 小于等于一页时, 允许bounce
        _collectionView.showsHorizontalScrollIndicator = NO;    // 不显示滚动条
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = nil;
        
        [_collectionView registerClass:[VHLWebViewShareItemCell class] forCellWithReuseIdentifier:vhl_share_item_cell_identifier];
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 6, 0, 6);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(VHL_ITEM_CELL_WIDTH, VHL_ITEM_CELL_HEIGHT);
    }
    return _flowLayout;
}

@end
