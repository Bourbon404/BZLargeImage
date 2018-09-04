//
//  BZLargeImage.h
//  BZLargeImage
//
//  Created by 郑伟 on 2018/9/4.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BZLargeImage : NSObject

+ (UIImage *)getRotationImage:(UIImage *)image rotation:(CGFloat)rotation;
+(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end
