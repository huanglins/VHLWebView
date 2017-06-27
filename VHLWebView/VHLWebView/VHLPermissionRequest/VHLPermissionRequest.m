//
//  VHLPermissionRequest.m
//  VHLWebView
//
//  Created by vincent on 2017/6/26.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "VHLPermissionRequest.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreTelephony/CTCellularData.h>

@interface VHLPermissionRequest()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, copy, nullable) VHLRequestResult requestResult;

@end

@implementation VHLPermissionRequest

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static VHLPermissionRequest *permissionRequest = nil;
    dispatch_once(&onceToken, ^{
        permissionRequest = [[VHLPermissionRequest alloc] init];
    });
    return permissionRequest;
}

/**************************************** 权 限 判 断 ****************************************/
/** 判断权限是否存在*/
- (BOOL)determinePermission:(VHLPermission)permission
{
    VHLPermissionAuthorizationStatus determine = [self authorizationPermission:permission];
    return determine == VHLAuthorizationStatusAuthorized;
}
- (VHLPermissionAuthorizationStatus)authorizationPermission:(VHLPermission)permission
{
    VHLPermissionAuthorizationStatus authorizationState = VHLAuthorizationStatusNotDetermined;
    switch (permission) {
        case VHLPhotoLibrary:       // 相册
            authorizationState = [self determinePhotoLibrary];
            break;
        case VHLCamera:
            authorizationState = [self determineCamera];
            break;
        case VHLMicrophone:
            authorizationState = [self determineMicrophone];
            break;
        case VHLLocationWhenInUse:
            authorizationState = [self determineLocationWhenInUse];
            break;
        case VHLLocationAllows:
            authorizationState = [self determineLocationAllows];
            break;
        case VHLCalendars:
            authorizationState = [self determineCalendars];
            break;
        case VHLReminders:
            authorizationState = [self determineReninders];
            break;
        case VHLHealth:
            authorizationState = [self determineHealth];
            break;
        case VHLUserNotification:
            authorizationState = [self determineUserNotification];
            break;
        case VHLContacts:
            authorizationState = [self determineContacts];
        case VHLNetwork:
            authorizationState = [self determineNetwork];
            break;
    }
    return authorizationState;
}
/** 1. 系统相册权限*/
- (VHLPermissionAuthorizationStatus)determinePhotoLibrary
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case PHAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
#else
    ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
    switch (authStatus) {
        case ALAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case ALAuthorizationStatusRestricted:
        case ALAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case ALAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
#endif
}
/** 2. 系统相机权限*/
- (VHLPermissionAuthorizationStatus)determineCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 3. 麦克风权限*/
- (VHLPermissionAuthorizationStatus)determineMicrophone
{
    AVAudioSessionRecordPermission authStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (authStatus) {
        case AVAudioSessionRecordPermissionUndetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case AVAudioSessionRecordPermissionDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case AVAudioSessionRecordPermissionGranted: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 4. 定位：使用时定位*/
- (VHLPermissionAuthorizationStatus)determineLocationWhenInUse
{
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 5. 定位：始终定位*/
- (VHLPermissionAuthorizationStatus)determineLocationAllows
{
    if (!self.manager) {
        if (!self.manager) {
            self.manager = [[CLLocationManager alloc] init];
            self.manager.delegate = self;
        }
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:{
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 6. 日历*/
- (VHLPermissionAuthorizationStatus)determineCalendars
{
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 7. 提醒事项*/
- (VHLPermissionAuthorizationStatus)determineReninders
{
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 8. 健康*/
- (VHLPermissionAuthorizationStatus)determineHealth
{
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:hkObjectType];
    switch (authStatus) {
        case HKAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case HKAuthorizationStatusSharingDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case HKAuthorizationStatusSharingAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 9. 通知*/
- (VHLPermissionAuthorizationStatus)determineUserNotification
{
    UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    switch (type) {
        case UIUserNotificationTypeNone: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case UIUserNotificationTypeBadge:
        case UIUserNotificationTypeSound:
        case UIUserNotificationTypeAlert: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
}
/** 10. 通讯录*/
- (VHLPermissionAuthorizationStatus)determineContacts
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (authStatus) {
        case CNAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case CNAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
#else
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    switch (authStatus) {
        case kABAuthorizationStatusNotDetermined: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case kABAuthorizationStatusRestricted:
        case kABAuthorizationStatusDenied: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case kABAuthorizationStatusAuthorized: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
#endif
}
/** 11. 网络判断 iOS9 以后*/
- (VHLPermissionAuthorizationStatus)determineNetwork
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    CTCellularDataRestrictedState authStatus = cellularData.restrictedState;
    switch (authStatus) {
        case kCTCellularDataRestrictedStateUnknown: {
            return VHLAuthorizationStatusNotDetermined;
            break;
        }
        case kCTCellularDataRestricted: {
            return VHLAuthorizationStatusForbid;
            break;
        }
        case kCTCellularDataNotRestricted: {
            return VHLAuthorizationStatusAuthorized;
            break;
        }
    }
#else
    return VHLAuthorizationStatusForbid;
#endif
}
/**************************************** 权 限 请 求 ****************************************/
/** 权限是否存在，如果权限不存在则请求权限*/
/*
 *  @param permission  权限类型
 *  @param title       非第一次请求权限时标题
 *  @param description 非第一次请求权限时副标题
 *  @param result      请求结果
 */
- (void)requestPermission:(VHLPermission)permission
                    title:(NSString *)title
              description:(NSString *)description
            requestResult:(VHLRequestResult)result
{
    if (result == nil) {
        result = ^(BOOL granted, NSError *error) {};
    }
    VHLPermissionAuthorizationStatus authorizationStatus = [self authorizationPermission:permission];
    switch (authorizationStatus) {
        case VHLAuthorizationStatusNotDetermined:
            // 第一次请求
            [self requestPermission:permission requestResult:result];
            return;
            break;
        case VHLAuthorizationStatusForbid:
            self.requestResult = (permission == VHLLocationAllows) ||
            (permission == VHLLocationWhenInUse) ? result : nil;
            break;
        case VHLAuthorizationStatusAuthorized:
            // 已经授权
            result(YES, nil);
            return;
            break;
    }
    // 跳转到设置页面，提示进行操作
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:description preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                [[UIApplication sharedApplication] openURL:url];
                                                            }
                                                        });
                                                    }];
    UIAlertAction *dontAllows = [UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSError *error = [NSError errorWithDomain:VHLErrorDomain               code:VHLForbidPermission                         userInfo:@{NSLocalizedDescriptionKey : @"禁止开启权限"}];
                                                           result(NO,error);
                                                           weakSelf.requestResult = nil;
                                                       }];
    [alert addAction:dontAllows];
    [alert addAction:setting];
    UIViewController *currentVC = [self currentViewController];
    [currentVC presentViewController:alert
                            animated:YES
                          completion:nil];
    
}
- (void)requestPermission:(VHLPermission)permission
            requestResult:(VHLRequestResult)result
{
    switch (permission) {
        case VHLPhotoLibrary:
            [self requestPhotoLibrary:result];
            break;
        case VHLCamera:
            [self requestCamera:result];
            break;
        case VHLMicrophone:
            [self requestMicrophone:result];
            break;
        case VHLLocationWhenInUse:
            [self requestLocationWhenInUse:result];
            break;
        case VHLLocationAllows:
            [self requestLocationAllows:result];
            break;
        case VHLCalendars:
            [self requestCalendars:result];
            break;
        case VHLReminders:
            [self requestReminders:result];
            break;
        case VHLHealth:
            [self requestHealth:result];
            break;
        case VHLUserNotification:
            [self requestUserNotification:result];
            break;
        case VHLContacts:
            [self requestContacts:result];
            break;
        case VHLNetwork:
            [self requestNetwork:result];
            break;
    }
}
/** 请求相册权限*/
- (void)requestPhotoLibrary:(VHLRequestResult)result
{
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            NSError *error;
            BOOL granted = NO;
            if (status == PHAuthorizationStatusAuthorized) {
                // 授权成功
                granted = YES;
            } else {
                // 授权失败
                error = [NSError errorWithDomain:VHLErrorDomain
                                            code:VHLFailueAuthorize
                                        userInfo:@{NSLocalizedDescriptionKey : @"授权失败"}];
            }
            result(granted, error);
        }];
    } else {
        // 授权失败
       NSError *error = [NSError errorWithDomain:VHLErrorDomain
                                    code:VHLUnsuportAuthorize
                                userInfo:@{NSLocalizedDescriptionKey : @"不支持授权"}];
       result(NO, error);
    }
}
/** 请求相机权限*/
- (void)requestCamera:(VHLRequestResult)result
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 NSError *error;
                                 if (granted) {
                                     NSLog(@"请求相机权限成功");
                                 }else {
                                     NSLog(@"请求相机权限失败");
                                     error = [NSError errorWithDomain:VHLErrorDomain
                                                                 code:VHLFailueAuthorize
                                                             userInfo:@{NSLocalizedDescriptionKey : @"授权失败"}];
                                 }
                                 result(granted, error);
                             }];
}
/** 请求麦克风权限*/
- (void)requestMicrophone:(VHLRequestResult)result
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        NSError *error;
        if (granted) {
            NSLog(@"请求麦克风权限成功");
        }else {
            NSLog(@"请求麦克风权限失败");
            error = [NSError errorWithDomain:VHLErrorDomain
                                        code:VHLFailueAuthorize
                                    userInfo:@{NSLocalizedDescriptionKey : @"授权失败"}];
        }
        result(granted, error);
    }];
}
/** 请求定位权限 - 使用时开启*/
- (void)requestLocationWhenInUse:(VHLRequestResult)result
{
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.requestResult = result;
    [self.manager requestWhenInUseAuthorization];
}
/** 请求定位权限 - 始终定位*/
- (void)requestLocationAllows:(VHLRequestResult)result
{
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.requestResult = result;
    [self.manager requestAlwaysAuthorization];
}
/** 请求日历权限*/
- (void)requestCalendars:(VHLRequestResult)result
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (granted) {
                                  NSLog(@"请求日历权限成功");
                              }else {
                                  NSLog(@"请求日历权限失败");
                              }
                              result(granted, error);
                          }];
}
/** 请求提醒事项权限*/
- (void)requestReminders:(VHLRequestResult)result
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (granted) {
                                  NSLog(@"请求提醒事项权限成功");
                              }else {
                                  NSLog(@"请求提醒事项权限失败");
                              }
                              result(granted, error);
                          }];
}
/** 请求健康权限*/
- (void)requestHealth:(VHLRequestResult)result
{
    if (![HKHealthStore isHealthDataAvailable]) {
        NSLog(@"不支持 Health");
        NSError *error = [NSError errorWithDomain:VHLErrorDomain
                                             code:VHLUnsuportAuthorize
                                         userInfo:@{NSLocalizedDescriptionKey : @"不支持授权"}];
        result(NO, error);
        return;
    }
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    // 分享 - 体重，身高，体重指数
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];
    // 读出 - 出生日期，生理性别，运动步数
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    // Request access
    [healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:readObjectTypes
                                       completion:^(BOOL success,
                                                    NSError *error) {
                                           if(success == YES){
                                               NSLog(@"请求健康权限成功");
                                           }
                                           else{
                                               NSLog(@"请求健康权限失败");
                                           }
                                           result(success, error);
                                       }];
}
/** 请求通知权限*/
- (void)requestUserNotification:(VHLRequestResult)result
{
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:
                                           UIUserNotificationTypeSound |
                                           UIUserNotificationTypeAlert |
                                           UIUserNotificationTypeBadge
                                                                            categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
}
/** 请求通讯录权限*/
- (void)requestContacts:(VHLRequestResult)result
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts
                    completionHandler:^(BOOL granted,
                                        NSError * _Nullable error) {
                        if (granted) {
                            NSLog(@"请求通讯录权限成功");
                        }else {
                            NSLog(@"请求通讯录权限失败");
                        }
                        result(granted, error);
                    }];

#else
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABAddressBookRequestAccessWithCompletion(addressBook,
                                             ^(bool granted,
                                               CFErrorRef error) {
                                                 if (granted) {
                                                     NSLog(@"请求通讯录权限成功");
                                                 }else {
                                                     NSLog(@"请求通讯录权限失败");
                                                 }
                                                 result(granted, (__bridge NSError *)(error));
                                             });
#endif
}
/** 请求网络权限*/
- (void)requestNetwork:(VHLRequestResult)result
{
    NSAssert(0, @"* * * * * * 网络手动授权还未实现 * * * * * *");
}
#pragma mark - Delegate --------------------------------------------------------
#pragma mark - Delegate - CLLocationManagerDelegate
// 定位权限变更
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.requestResult) {
            self.requestResult(YES, nil);
            self.requestResult = nil;
        }
    }
}
#pragma mark - private
- (UIViewController *)currentViewController {
    UIViewController *currentVC = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWindow in windows) {
            if (tmpWindow.windowLevel == UIWindowLevelNormal) {
                window = tmpWindow;
                break;
            }
        }
    }
    UIView *frontV = [[window subviews] objectAtIndex:0];
    id nextReqoner = [frontV nextResponder];
    if ([nextReqoner isKindOfClass:[UIViewController class]]) {
        currentVC = nextReqoner;
    }else {
        currentVC = window.rootViewController;
    }
    return currentVC;
}
@end
