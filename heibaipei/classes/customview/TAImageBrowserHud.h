//
//  TAImageBrowserHud.h
//  Edu-Client
//
//  Created by yxf on 2017/1/18.
//  Copyright © 2017年 jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAImageBrowserHud : UIView

/**
 loading圈显示并开始旋转
 */
-(void)startAnimation;

/**
 loading圈隐藏并停止旋转
 */
-(void)stopAnimation;

@end
