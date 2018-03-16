//
//  PhotoDemosCell.h
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PhotoDemosCellHeight 80

typedef void(^SelectDemoImg)(NSString *img);

@interface PhotoDemosCell : UITableViewCell

/*tap img*/
@property (nonatomic,copy)SelectDemoImg tapImg;

@end
