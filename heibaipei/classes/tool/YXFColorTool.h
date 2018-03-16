//
//  YXFColorTool.h
//  heibaipei
//
//  Created by yxf on 2018/3/12.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXFColorTool : NSObject

+(instancetype)shareInstance;

/**多个撤销点 */
@property(nonatomic,strong)NSMutableArray *revokePoints;

/**
 撤销操作
 */
- (UIImage *)revokeOption:(UIImage *)image;

- (UIImage *)floodFillImage:(UIImage *)image fromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor;

@end
