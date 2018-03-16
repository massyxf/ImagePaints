//
//  SelectColorViewController.h
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectColorViewController;

@protocol SelectColorViewControllerDelegate<NSObject>

-(void)selectVc:(SelectColorViewController *)selectVc selectColor:(UIColor *)color;

@end

@interface SelectColorViewController : UIViewController

/*delegate*/
@property (nonatomic,weak)id <SelectColorViewControllerDelegate>delegate;

/*originColor*/
@property (nonatomic,strong)UIColor *originColor;

@end
