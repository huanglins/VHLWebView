//
//  TestViewController1.m
//  VHLWebView
//
//  Created by vincent on 2017/8/24.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "TestViewController1.h"
#import "TestViewController2.h"
#import "VHLNavigation.h"

@interface TestViewController1 ()

@end

@implementation TestViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"隐藏导航栏1";
    self.view.backgroundColor = [UIColor blackColor];
    [self vhl_setNavBackgroundColor:[UIColor colorWithRed:0.35 green:0.42 blue:0.58 alpha:1.00]];
    [self vhl_setNavigationSwitchStyle:VHLNavigationSwitchStyleFakeNavBar];
    //[self vhl_setNavBarBackgroundImage:[UIImage imageNamed:@"millcolorGrad"]];
    //[self vhl_setNavBarBackgroundAlpha:0.f];
    [self vhl_setNavBarShadowImageHidden:YES];
    [self vhl_setNavBarBackgroundAlpha:1.0f];
    [self vhl_setNavBarTintColor:[UIColor blackColor]];
    [self vhl_setNavBarTitleColor:[UIColor blackColor]];
    [self vhl_setStatusBarStyle:UIStatusBarStyleDefault];
    self.navBackButtonColor = [UIColor blackColor];
    //[self vhl_setNavBarHidden:YES];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    //z
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    [button setTitle:@"VC1 NEXT" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.center = self.view.center;
    
    [button addTarget:self action:@selector(gonext:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)gonext:(UIButton *)sender {
    TestViewController2 *vc2 = [[TestViewController2 alloc] init];
    [self.navigationController pushViewController:vc2 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// ---------------------------- 屏幕旋转
// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}
// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
