//
//  UINavigationController+VHLPopNavigationController.m
//  PingLianBank
//
//  Created by vincent on 16/8/24.
//  Copyright © 2016年 PingLianBank. All rights reserved.
//

#import "VHLPopNavigationController.h"
#import <objc/runtime.h>

@implementation UINavigationController (Injection)

// load方法程序运行时自动加载
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(navigationBar:shouldPopItem:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(vhl_navigationBar:shouldPopItem:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (BOOL)vhl_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    BOOL shouldPopItemAfterPopViewController = [[self valueForKey:@"_isTransitioning"] boolValue];
    
    if (shouldPopItemAfterPopViewController) {
        return [self vhl_navigationBar:navigationBar shouldPopItem:item];
    }
    
    if (self.popHandler) {
        BOOL shouldPopItemAfterPopViewController = self.popHandler(navigationBar, item);
        
        if (shouldPopItemAfterPopViewController) {
            return [self vhl_navigationBar:navigationBar shouldPopItem:item];
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            ((UIView *)[[self.navigationBar subviews] lastObject]).alpha = 1;
        }];
        
        return shouldPopItemAfterPopViewController;
    } else {
        UIViewController *viewController = [self topViewController];
        
        if ([viewController respondsToSelector:@selector(vhl_navigationBar:shouldPopItem:)]) {
            BOOL shouldPopItemAfterPopViewController = [(id<VHLNavigationBackItemProtocol>)viewController navigationBar:navigationBar shouldPopItem:item];
            
            if (shouldPopItemAfterPopViewController) {
                return [self vhl_navigationBar:navigationBar shouldPopItem:item];
            }
            
            [UIView animateWithDuration:0.25 animations:^{
                ((UIView *)[[self.navigationBar subviews] lastObject]).alpha = 1;
            }];
            
            return shouldPopItemAfterPopViewController;
        }
    }
    
    return [self vhl_navigationBar:navigationBar shouldPopItem:item];
}

- (VHLNavigationItemPopHandler)popHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPopHandler:(VHLNavigationItemPopHandler)popHandler {
    objc_setAssociatedObject(self, @selector(popHandler), [popHandler copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
