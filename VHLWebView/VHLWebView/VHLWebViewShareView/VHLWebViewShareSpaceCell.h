//
//  VHLWebViewSpaceCell.h
//  VHLWebView
//
//  Created by vincent on 16/8/29.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VHLWebViewShareSpaceCell : UITableViewCell

@property (nonatomic, strong) NSArray *itemArray;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
