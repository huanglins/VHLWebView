//
//  TestViewController2.m
//  VHLWebView
//
//  Created by vincent on 2017/8/24.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "TestViewController2.h"
#import "TestViewController1.h"
#import "VHLNavigation.h"


@interface TestViewController2 ()

@end

@implementation TestViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"隐藏导航栏2";
    self.view.backgroundColor = [UIColor whiteColor];
    [self vhl_setNavBackgroundColor:[UIColor colorWithRed:0.21 green:0.56 blue:0.86 alpha:1.00]];
    //[self vhl_setNavigationSwitchStyle:VHLNavigationSwitchStyleFakeNavigationBar];
    [self vhl_setNavBarBackgroundImage:[UIImage imageNamed:@"imageNav"]];  // millcolorGrad
    //[self vhl_setNavBarBackgroundAlpha:0.f];
    [self vhl_setNavBarShadowImageHidden:YES];
    [self vhl_setNavBarBackgroundAlpha:1.0f];
    [self vhl_setNavBarTintColor:[UIColor whiteColor]];
    [self vhl_setNavBarTitleColor:[UIColor whiteColor]];
    [self vhl_setStatusBarStyle:UIStatusBarStyleLightContent];
    //[self vhl_setNavBarHidden:YES];
    
    //
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    [button setTitle:@"VC2 NEXT" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.center = self.view.center;
    
    [button addTarget:self action:@selector(gonext:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return NO;
}
// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)vhl_statusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)gonext:(UIButton *)sender {
    TestViewController1 *vc1 = [[TestViewController1 alloc] init];
    [self.navigationController pushViewController:vc1 animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
