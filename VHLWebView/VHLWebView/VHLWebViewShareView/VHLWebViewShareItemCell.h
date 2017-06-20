//
//  VHLWebViewShareItemCell.h
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHLWebViewShareItem.h"

static NSString *vhl_share_item_cell_identifier = @"VHLShareItemCell";

@interface VHLWebViewShareItemCell : UICollectionViewCell

@property (nonatomic, strong) VHLWebViewShareItem *item;

@end
