//
//  VHLPermissionRequest.h
//  VHLWebView
//
//  Created by vincent on 2017/6/26.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VHLErrorDomain @"VHLErrorDomain"

/** 权限列表*/
typedef enum {
    VHLPhotoLibrary,            // 相册
    VHLCamera,                  // 相机
    VHLMicrophone,              // 麦克风
    VHLLocationWhenInUse,       // 使用时定位
    VHLLocationAllows,          // 始终定位
    VHLCalendars,               // 日历
    VHLReminders,               // 提醒事项
    VHLHealth,                  // 健康更新
    VHLUserNotification,        // 通知
    VHLContacts,                // 通讯录
    VHLNetwork,                 // 网络
} VHLPermission;

/** 权限请求结果*/
typedef enum {
    VHLAuthorizationStatusNotDetermined,  // 第一次请求授权
    VHLAuthorizationStatusAuthorized,     // 已经授权成功
    VHLAuthorizationStatusForbid          // 非第一次请求授权
} VHLPermissionAuthorizationStatus;

/** 权限错误类别 code*/
typedef enum {
    VHLForbidPermission,        // 禁止许可
    VHLFailueAuthorize,         // 错误授权
    VHLUnsuportAuthorize,       // 不支持授权
} VHLErrorCode;

/** block 回调*/
typedef void(^VHLRequestResult)(BOOL granted, NSError *error);

/** 系统权限请求判断*/
@interface VHLPermissionRequest : NSObject

/** 单例*/
+ (instancetype)shareInstance;

/** 判断权限是否存在*/
- (BOOL)determinePermission:(VHLPermission)permission;
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
            requestResult:(VHLRequestResult)result;

@end

/*
    来源
    https://github.com/AppleDP/WQPermissionRequest
 */
/*
    *** iOS 10 以后需要在 info.plist 中添加所有使用到的权限，否则会提交失败 ***
 
    Privacy - Photo Library Usage Description
    Privacy - Camera Usage Description
    Privacy - Microphone Usage Description
    Privacy - Location Usage Description
    Privacy - Location Always Usage Description
    Privacy - Calendars Usage Description
    Privacy - Reminders Usage Description
    Privacy - Contacts Usage Description
 */
