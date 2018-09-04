//
//  BZLargeImage.m
//  BZLargeImage
//
//  Created by 郑伟 on 2018/9/4.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "BZLargeImage.h"

@implementation BZLargeImage

+ (UIImage *)getRotationImage:(UIImage *)image rotation:(CGFloat)rotation {
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    CGAffineTransform transform = CATransform3DGetAffineTransform([self rotateTransform:CATransform3DIdentity clockwise:NO angle:rotation]);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);

    return result;
}
+ (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise angle:(CGFloat)angle {
    CGFloat arg = angle*M_PI / 180.0f;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    CGFloat _flipState1 = 0;
    CGFloat _flipState2 = 0;
    transform = CATransform3DRotate(transform, _flipState1*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, _flipState2*M_PI, 1, 0, 0);
    
    return transform;
}

+(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    CGFloat scale = 1;
    if (size.width != CGFLOAT_MAX) {
        scale = (CGFloat) size.width / image.size.width;
    } else if (size.height != CGFLOAT_MAX) {
        scale = (CGFloat) size.height / image.size.height;
    }
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}
@end
