//
//  UIImage+VHLWebQRCode.m
//  VHLWebView
//
//  Created by vincent on 2017/6/26.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "UIImage+VHLWebQRCode.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (VHLWebQRCode)

- (NSString *)qrCodeByVHLWeb
{
    NSData *imageData = UIImagePNGRepresentation(self);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *array = [detector featuresInImage:ciImage];
    CIQRCodeFeature *feature = [array firstObject];
    NSString *result = feature.messageString;
    
    return result;
}

@end
