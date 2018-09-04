//
//  BZImage.h
//  BZLargeImage
//
//  Created by 郑伟 on 2018/9/4.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BZImage : NSObject

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

+ (UIImage *)image:(UIImage *)image transformtoSize:(CGSize)Newsize;

@end
