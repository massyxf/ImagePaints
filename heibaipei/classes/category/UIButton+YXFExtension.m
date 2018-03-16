//
//  UIButton+Extension.m
//  heibaipei
//
//  Created by yxf on 2018/3/12.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "UIButton+YXFExtension.h"

@implementation UIButton (YXFExtension)

+(UIButton *)customBtnWithTarget:(id)obj action:(SEL)action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:obj action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
