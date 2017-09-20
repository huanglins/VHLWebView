//
//  AppDelegate.m
//  VHLWebView
//
//  Created by vincent on 16/8/24.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenShareHeader.h"

#import "BaseNavigationC.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [[UINavigationBar appearance]setBarTintColor:[UIColor whiteColor]];
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -2) forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setShadowImage:[self imageWithColor:[UIColor colorWithRed:0.8354 green:0.8354 blue:0.8354 alpha:1.0]]];
    
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewcontroller1"];
    BaseNavigationC *navigationC = [[BaseNavigationC alloc] initWithRootViewController:vc];
    self.window.rootViewController = navigationC;
    
    [OpenShare connectQQWithAppId:@"1103194207"];
    [OpenShare connectWeixinWithAppId:@"wx4380971b4ff92e6d"];
    
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"点击链接回调:[%@]-[%@]-[%@]",url,sourceApplication,annotation);
    //第二步：添加回调 - 判断分享是否能处理回调
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }
    // 判断是否能处理其他回调
    NSLog(@"参数:%@",url.parameterString);
    //这里可以写上其他OpenShare不支持的客户端的回调，比如支付宝等。
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UIImage *)imageWithColor:(UIColor *)color
{
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return theImage;
}

@end
