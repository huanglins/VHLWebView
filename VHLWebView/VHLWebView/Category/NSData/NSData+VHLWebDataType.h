//
//  NSData+VHLWebDataType.h
//  VHLWebView
//
//  Created by vincent on 2017/6/28.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (VHLWebDataType)

/** 当前 data 的文件类型*/
- (NSString *)vhlweb_dataType;
/** 当前数据是否是 Image*/
- (BOOL)vhlweb_isImageData;

@end
