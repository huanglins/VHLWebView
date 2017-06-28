//
//  NSData+VHLWebDataType.m
//  VHLWebView
//
//  Created by vincent on 2017/6/28.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "NSData+VHLWebDataType.h"

@implementation NSData (VHLWebDataType)

/*
 当前 data 的文件类型
 */
- (NSString *)vhlweb_dataType
{
    uint8_t c;
    [self getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([self length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[self subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}
/** 当前数据是否是 Image*/
- (BOOL)vhlweb_isImageData
{
    uint8_t c;
    [self getBytes:&c length:1];
    
    if (c == 0xFF || c == 0x89 || c == 0x47 || c == 0x49 || c == 0x4D || c == 0x52 || c == 0x52) {
        return YES;
    }
    return NO;
}
@end
