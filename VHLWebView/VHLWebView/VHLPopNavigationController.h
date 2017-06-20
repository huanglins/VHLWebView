//
//  UINavigationController+VHLPopNavigationController.h
//  PingLianBank
//
//  Created by vincent on 16/8/24.
//  Copyright © 2016年 PingLianBank. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^VHLNavigationItemPopHandler)(UINavigationBar *navigationBar,UINavigationItem *navigationItem);

@protocol VHLNavigationBackItemProtocol <NSObject>
@optional
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;

@end

@interface UINavigationController (Injection)

@property (nonatomic, copy) VHLNavigationItemPopHandler popHandler;

@end
NS_ASSUME_NONNULL_END
