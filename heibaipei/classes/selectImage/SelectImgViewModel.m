//
//  SelectImgViewModel.m
//  heibaipei
//
//  Created by yxf on 2018/3/15.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "SelectImgViewModel.h"
#import "YPKImageModel.h"
#import "YPKManager.h"
#import <GPUImage/GPUImage.h>

@implementation SelectImgViewModel

+(void)selectImgModel:(YPKImageModel *)model completion:(void (^)(void))completion{
    NSMutableDictionary *note = [NSMutableDictionary dictionary];
    note[@"image"] = model.image;
    if (!model.isAppPic) {
        UIImage *bgImg = [YPKManager bigImage:model.asset];
        GPUImageFilter *filter = [[GPUImageSketchFilter alloc] init];
        UIImage *newImg = [self image:bgImg filter:filter];
        
        note[@"image"] = newImg;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HBPNote_SelectImg object:nil userInfo:note];
    completion();
}

+(UIImage *)image:(UIImage *)img filter:(GPUImageFilter *)filter{
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:img];
    [pic addTarget:filter];
    
    [filter useNextFrameForImageCapture ];
    [pic processImage];
    UIImage *newImg = [filter imageFromCurrentFramebuffer];
    return  newImg;
}


@end
