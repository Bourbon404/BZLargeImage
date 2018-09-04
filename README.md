## iOS 针对大图片进行旋转、缩放操作

由于`iPhone`的硬件性能限制，直到`iPhone 6s`开始，才将最大内存拓展到`2G`。
可即使是如此，也不代表一个应用可使用的空间是`2G`。
一张`10000 x 10000`的图片，如果通过`UIImageJPEGRepresentation`方法将图片转成内存数据，会有一个峰值波动。
这里的峰值其实是图片在解压时产生的位图数据所占空间，然后才转换成我们可以操作的`NSData`。
其计算公式是 `W x H x 4 / 1024 / 1024`  也就是 `10000 x 10000 x4 /1024 / 1024 = 381.4(M)`。
这里会产生381M的消耗，及时会被回收，但是想一下，如果图片尺寸很大，数量很多的时候，很容易就会发生异常了。


接下来说下具体的操作

### 旋转

我们知道如果对一个`UIImage`对象进行旋转操作，可以有如下的方式

>  1. 通过 `CGContextDrawImage` 进行图片绘制

```
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {

    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;

    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
        break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
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
````

  这里有一个问题是，这里会创建一个新的图片大小空间的，然后进行重新绘制。可能会存在一个隐患，就是当图片尺寸过大的时候，就会出现内存占用过高的情况

>2. 接下来介绍一种另辟蹊径的解决方法--通过给图片添加滤镜的方式。
既然操作的对象是图片，那么它就会各种滤镜展示。系统给我们提供了多大一百多种滤镜，这里的滤镜不单只颜色等状态发生变化。
这其中就有我们需要的滤镜`Key` `inputTransform`。

```
+ (UIImage *)getRotationImage:(UIImage *)image rotation:(CGFloat)rotation {

    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];

    [filter setDefaults];
    CGAffineTransform transform = CATransform3DGetAffineTransform([self rotateTransform:CATransform3DIdentity clockwise:NO angle:rotation]);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];

    //根据滤镜设置图片
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
    //进行形变
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    CGFloat _flipState1 = 0;
    CGFloat _flipState2 = 0;
    transform = CATransform3DRotate(transform, _flipState1*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, _flipState2*M_PI, 1, 0, 0);

    return transform;
} 
```
  通过这种操作，可以利用`GPU`来进行图片操作，可以一定程度的降低消耗，节约资源。

### 缩放

  既然图片很大，那么我们可以通过缩放的方式，来减小图片的尺寸，减少内存消耗，进而降低异常风险。
我们通常采用`UIImage`提供的系统方法`drawInRect` 及其一系列的方法，来进行图片缩放。
可是这种操作的缺陷和最开始介绍的旋转一样，其实质都是进行图片的重新绘制。

>1. 通过绘制图片的方式进行图片缩放
```
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
```
这里是内存消耗。通过看图可以发现，针对大图，在进行缩放的时候，内存消耗的峰值能达到426M，耗时在1.5s左右
由于我们使用的手机是`iPhone X`，在更低端的设备上，这是多么大的损耗，很容易发生异常
![缩放1](http://www.bourbonz.cn/wp-content/uploads/2018/09/缩放1.png)

>2. 既然上面的方法损耗很大，我们来看下另外的一种方式。

先看下内存消耗
![缩放2](http://www.bourbonz.cn/wp-content/uploads/2018/09/缩放2.png)

通过图上可以看出，在进行图片缩放的时候，内存有小幅增加，产生的消耗在18M，耗时也在1.5s左右。
这样的效果是非常显著的。下面来看代码
```
+(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {

    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    //创建一个input image类型的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    //设置默认的滤镜效果
    [filter setDefaults];

    //设置缩放比例
    CGFloat scale = 1;
    if (size.width != CGFLOAT_MAX) {
        scale = (CGFloat) size.width / image.size.width;
    } else if (size.height != CGFLOAT_MAX) {
        scale = (CGFloat) size.height / image.size.height;
    }

    //进行赋值
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];

    //通过GPU的方式来进行处理
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    //根据滤镜输出图片
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    //创建UIImage 对象，并释放资源
    UIImage *result = [UIImage imageWithCGImage:cgImage];

    CGImageRelease(cgImage);

    return result;
}
```

可以发现我们这里使用的和旋转是同样的方式。通过给图片添加滤镜能够很安全的实现我们的需求。

### 总结
>1. 针对巨幅图片操作，可以采用这种思路：先生成一个尺寸小的缩略图，然后在进行各种操作，可以降低资源消耗；
>2. 通过`CoreImage.framework`来进行图片处理。
>3. 之前一直对`CoreImage.framework`的理解，只是其能够对图片和视频添加那种可见的滤镜，未曾想过这种滤镜也支持缩放和旋转。


? 为什么`CoreImage.framework`的方式能够很安全呢？
该框架从`iOS 5`开始投入使用，通过对`CoreGraphics.framework，CoreVideo.framework，和Image I/O.framework`进行数据处理，
可以自由在`CPU`和`GPU`之间切换运算方式，
可以最大限度的利用`GPU`来进行计算，降低内存消耗，
甚至可以对视频进行实时滤镜处理。
针对不能通过原生对`UIView`进行`transform`操作的时候，`CoreImage.framework`会是你的朋友。



