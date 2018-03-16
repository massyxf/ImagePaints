//
//  AddImgViewModel.h
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CameraImgBlock)(UIImage *img);

@interface AddImgViewModel : NSObject

+(instancetype)initWithVc:(UIViewController *)vc;

-(void)startCameraCompletion:(CameraImgBlock)completion;

@end
