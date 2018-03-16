//
//  ColorConfig.m
//  heibaipei
//
//  Created by yxf on 2018/3/15.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "ColorConfig.h"

@implementation ColorConfig

+(instancetype)shareInstance{
    static ColorConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[ColorConfig alloc] init];
    });
    return config;
}

-(instancetype)init{
    if (self = [super init]) {
        self.baseImg = [UIImage imageNamed:@"1.png"];
        self.currentColor = [UIColor redColor];
        self.scaleRate = 1;
    }
    return self;
}

-(void)setCurrentColor:(UIColor *)currentColor{
    _currentColor = currentColor;
    if (_currentColor == [UIColor blackColor]) {
        _currentColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1];
        
    }
}

@end
