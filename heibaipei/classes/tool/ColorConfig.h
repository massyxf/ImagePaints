//
//  ColorConfig.h
//  heibaipei
//
//  Created by yxf on 2018/3/15.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorConfig : NSObject

+(instancetype)shareInstance;

/*base image*/
@property (nonatomic,strong)UIImage *baseImg;

/*current color*/
@property (nonatomic,strong)UIColor *currentColor;

/*scale rate*/
@property (nonatomic,assign)CGFloat scaleRate;

@end
