//
//  ImgScrollView.m
//  heibaipei
//
//  Created by yxf on 2018/3/12.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "ImgScrollView.h"
#import "YXFColorTool.h"
#import "ColorConfig.h"
#import <Masonry/Masonry.h>

@interface ImgScrollView ()<UIScrollViewDelegate>

/*img view*/
@property (nonatomic,weak)UIImageView *imgView;

@end

@implementation ImgScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imgView = [[UIImageView alloc] init];
        [self addSubview:imgView];
        imgView.image = [UIImage imageNamed:@"1.png"];
        _imgView = imgView;
        self.delegate = self;
        self.maximumZoomScale = 8;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}



-(void)layoutSubviews{
    [super layoutSubviews];
    if (CGRectEqualToRect(_imgView.frame, CGRectZero)) {
        _imgView.frame = self.bounds;
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imgView;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (touches.count == 1) {
        CGPoint point = [[touches anyObject] locationInView:self];
        CGFloat currentWidth = CGRectGetWidth(self.frame) * self.zoomScale;
        [ColorConfig shareInstance].scaleRate = _imgView.image.size.width / currentWidth;
        UIImage *resultImg = [[YXFColorTool shareInstance] floodFillImage:_imgView.image fromPoint:point withColor:[ColorConfig shareInstance].currentColor];
        if (resultImg != nil) {
            _imgView.image = resultImg;
        }
    }
}



@end
