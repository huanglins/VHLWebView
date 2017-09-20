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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    NSLog(@"%@",libraryDir);
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
    NSString *urlString = @"http://183.63.131.106:40013/extService/ghbExtService.do";
    
    NSString *post_data = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_data" ofType:nil]] encoding:NSUTF8StringEncoding];
    NSString *trans_code = @"OGW00090";
//    post_data = [post_data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    trans_code = [trans_code stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"\n" withString:@"%5Cn"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"\t" withString:@"%5Ct"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
//    post_data = [post_data stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    NSString *postString = [NSString stringWithFormat:@"\"RequestData\":\"%@\",\"transCode\":\"%@\"", post_data,trans_code];
//    postString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                        (CFStringRef)postString,
//                                                                                        NULL,
//                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
//                                                                                        kCFStringEncodingUTF8));
    //postString = [postString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    //postString = [postString stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
    //postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    NSData *data = [postString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
//    NSDictionary *pad = @{
//                          @"RequestData":post_data,
//                          @"transCode":trans_code
//                          };
    
    //VHLWebViewController *webVC = [[VHLWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.105:8020/vapi/hybrid.html"]];
//    VHLWebViewController *webVC = [[VHLWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://183.63.131.106:40013/extService/ghbExtService.do?RequestData=001X11++++++++++00000256159324BBBF92C7C0478F8B25A1E73FC83D83F9C09602F1B05A46DA89841D895FEC05B19A896BC48AA2C9724A24774BC107B845FA4B8A2638DFECBD58AAEF3158EBE849585EB4C606A82DC821674428673530889105313D0970A73613886AF6AF56A08989A1BD172D5FC1DF3B79128855E749CC89037AE66909FD0A914A737C02%3C%3Fxml+version%3D%221.0%22+encoding%3D%22UTF-8%22%3F%3E%3CDocument%3E%3Cheader%3E%3CchannelCode%3EP2P189%3C%2FchannelCode%3E%3CchannelFlow%3EP2P1892017062115521600000%3C%2FchannelFlow%3E%3CchannelDate%3E20170621%3C%2FchannelDate%3E%3CchannelTime%3E155217%3C%2FchannelTime%3E%3CencryptData%2F%3E%3C%2Fheader%3E%3Cbody%3E%3CTRANSCODE%3EOGW00092%3C%2FTRANSCODE%3E%3CXMLPARA%3E8%2FEpHCRRszYA4s1cCbhwp6%2FT0Kf7TToiDRkELkihBekJV2pspTuiQThuAPEE43b8CVdqbKU7okEit7dQy5VAB8lMPBj2K%2BtCT4%2Bh1UhiU5JZEwS4bJBjwhYBTGOp36KMO9SKS8uM04txovDC1y1PakADu7Thq7OtCu%2FRA7RFecUal21NcBb0xKWHNlbdiC4VkCbm5LbDqJrtHRh6KxxndFQtM5PZUHzt0Ch5eBtsf63Og1t74k%2FSzyhYaiDsl5f27wngHODOLr8h5P7Y6VykfHRVgCKN2Tb2uJFKsFHSjXIOaGl382N6Q%2F%2BFKFMi%2BMpEzQzntKHRyhjs2bIcaqt2Bq%2B0jtQ6RHUUMwaxyfRFIKW%2BB18SfQ1iA%2Fe0sKVJgqbXIVosTr25%2FN6Zdd9Yd%2BthN0jMY5MxneTBnNKHF5j5Ci0BWjYLKOobipvT6%2By3HmvLBudn8mQLBGg%3D%3C%2FXMLPARA%3E%3C%2Fbody%3E%3C%2FDocument%3E&transCode=OGW00092"]];
    
    //VHLWebViewController *webVC = [[VHLWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.pingliandai.com/integ/index.html"]];   // https://www.pingliandai.com/integ/index.html
    VHLWebViewController *webVC = [[VHLWebViewController alloc] init];
    //[webVC loadPostRequestURL:urlString postData:pad title:@""];
    //VHLWebViewController *webVC = [[VHLWebViewController alloc] initWithRequest:request];
    //webVC.hidesNavigationBarWhenPushed = YES;
    [webVC loadURL:[NSURL URLWithString:@"https://www.bing.com"]];
    webVC.progressTintColor = [UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0];
    webVC.navTitleColor = [UIColor colorWithRed:0.2143 green:0.4838 blue:0.9132 alpha:1.0];
    webVC.webScrollViewBGColor = [UIColor colorWithRed:0.18 green:0.19 blue:0.20 alpha:1.00];
    //webVC.navBackButtonImage = [UIImage imageNamed:@"back"];
    webVC.navBackButtonTitle = @"首页";
    webVC.allowsLinkPreview = YES;
    
    [webVC vhl_setNavBarShadowImageHidden:NO];
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
