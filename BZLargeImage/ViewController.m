//
//  ViewController.m
//  BZLargeImage
//
//  Created by 郑伟 on 2018/9/4.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "BZImage.h"
#import "BZLargeImage.h"
@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *pickerButton;
@end

@implementation ViewController

- (void)loadView {
    
    [super loadView];
    CGRect rect = self.view.bounds;
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    [self.imageView setContentMode:(UIViewContentModeScaleAspectFit)];
    [self.view addSubview:self.imageView];
    
    self.pickerButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.pickerButton setTitle:@"打开相册" forState:(UIControlStateNormal)];
    [self.pickerButton setFrame:CGRectMake(0, 100, 100, 100)];
    [self.pickerButton addTarget:self action:@selector(showPicker) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.pickerButton];
    
    self.button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.button setTitle:@"操作" forState:(UIControlStateNormal)];
    [self.button setFrame:CGRectMake(self.view.bounds.size.width - 100, 100, 100, 100)];
    [self.button addTarget:self action:@selector(didClickButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.button];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

- (void)showPicker {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
       
        if (status == PHAuthorizationStatusAuthorized) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
}

- (void)didClickButton:(UIButton *)button {
    
    
    UIImage *image = self.imageView.image;
    NSLog(@"开始操作 %@",image);
    UIImage *result = [BZImage image:image rotation:(UIImageOrientationLeft)];
//    UIImage *result = [BZLargeImage getRotationImage:image rotation:90];
    
//    UIImage *result = [BZLargeImage resizeImage:image toSize:CGSizeMake(1000, 1000)];
//    UIImage *result = [BZImage image:image transformtoSize:CGSizeMake(1000, 1000)];
    NSLog(@"操作完毕 %@",result);
    self.imageView.image = result;
}

#pragma mark Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *assetsLibrary = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetsLibrary] options:nil];
    PHAsset *asset = result.firstObject;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) contentMode:(PHImageContentModeDefault) options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        NSLog(@"选取结果 %@",result);
        [self.imageView setImage:result];
    }];
}
@end
