//
//  SelectImgViewModel.h
//  heibaipei
//
//  Created by yxf on 2018/3/15.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YPKImageModel;

@interface SelectImgViewModel : NSObject

+(void)selectImgModel:(YPKImageModel *)model completion:(void(^)(void))completion;

@end
