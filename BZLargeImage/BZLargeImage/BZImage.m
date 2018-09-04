//
//  BZImage.m
//  BZLargeImage
//
//  Created by 郑伟 on 2018/9/4.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "BZImage.h"

@implementation BZImage

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {
    
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
            
         case UIImageOrientationLeft:
            rotate =M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX=0;
            translateY= -rect.size.width;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
            
         case UIImageOrientationRight:
            
             rotate =3 *M_PI_2;
             rect =CGRectMake(0,0,image.size.height, image.size.width);
             translateX= -rect.size.height;
             translateY=0;
             scaleY =rect.size.width/rect.size.height;
             scaleX =rect.size.height/rect.size.width;
             break;
            
         case UIImageOrientationDown:
            
             rotate =M_PI;
             rect =CGRectMake(0,0,image.size.width, image.size.height);
             translateX= -rect.size.width;
             translateY= -rect.size.height;
             break;
            
         default:
            
             rotate =0.0;
             rect =CGRectMake(0,0,image.size.width, image.size.height);
             translateX=0;
             translateY=0;
             break;
     }
    

    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
}

+ (UIImage *)image:(UIImage *)image transformtoSize:(CGSize)Newsize {
    // 创建一个bitmap的context
    UIGraphicsBeginImageContext(Newsize);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, Newsize.width, Newsize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *TransformedImg=UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return TransformedImg;
}
@end
