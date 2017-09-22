//
//  ViewController.m
//  VHLWebView
//
//  Created by vincent on 16/8/24.
//  Copyright © 2016年 Darnel Studio. All rights reserved.
//

#import "ViewController.h"
#import "VHLWebViewController.h"
#import "VHLNavigation.h"

#import "TestViewController1.h"
//#import <UINavigationController+FDFullscreenPopGesture.h>
//#import "UINavigationController+JZExtension.h"
//#import <UINavigationController+JZExtension.h>
//#import <UIViewController+JZExtension.h>

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    NSLog(@"%@",libraryDir);
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    
    [self vhl_setNavBarHidden:YES];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation     NS_AVAILABLE_IOS(6_0)
{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}
// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goWebView:(id)sender {
    VHLWebViewController *webVC = [[VHLWebViewController alloc] init];
    [webVC loadURL:[NSURL URLWithString:@"https://www.bing.com"]];
    webVC.progressTintColor = [UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0];
    webVC.navButtonTitleColor = [UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0];
    webVC.webScrollViewBGColor = [UIColor whiteColor];
    webVC.navBackButtonTitle = @"首页";
    webVC.allowsLinkPreview = YES;
    webVC.fullScreenDisplay = YES;
    webVC.hideSourceLabel = YES;
    //webVC.webBounces = NO;
    [webVC vhl_setNavBarShadowImageHidden:NO];
    [webVC vhl_setNavBarBackgroundAlpha:0.0f];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)goUIWebview:(id)sender {
    //TowViewController *vc = [[TowViewController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goVC:(id)sender {
//    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewcontroller1"];
//    [vc vhl_setNavBarBarTintColor:[UIColor greenColor]];
//    [vc vhl_setNavBarShadowImageHidden:YES];
//    [self.navigationController pushViewController:vc animated:YES];
    TestViewController1 *vc1 = [[TestViewController1 alloc] init];
    [self.navigationController pushViewController:vc1 animated:YES];
}

- (IBAction)qrcodeClick:(id)sender {
    //调用相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//选中图片的回调
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *content = @"" ;
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        content = result.messageString;
    }
    //进行处理(音效、网址分析、页面跳转等)
}
@end
