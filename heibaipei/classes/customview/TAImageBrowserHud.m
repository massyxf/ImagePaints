//
//  TAImageBrowserHud.m
//  Edu-Client
//
//  Created by yxf on 2017/1/18.
//  Copyright © 2017年 jack. All rights reserved.
//

#import "TAImageBrowserHud.h"

static NSString * const animationKey = @"rotaionAniamtion";

@implementation TAImageBrowserHud

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2.0, height / 2.0)
                                                            radius:width / 2.0
                                                        startAngle:0
                                                          endAngle:2 *M_PI
                                                         clockwise:YES];
        //灰色管道
        CAShapeLayer *bottomLayer = [CAShapeLayer layer];
        bottomLayer.path = path.CGPath;
        bottomLayer.fillColor = [UIColor clearColor].CGColor;
        bottomLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        bottomLayer.lineWidth = 3;
        bottomLayer.strokeStart = 0;
        bottomLayer.strokeEnd = 1.0;
        [self.layer addSublayer:bottomLayer];
        
        //白色管道
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 3;
        shapeLayer.strokeStart = 0;
        shapeLayer.strokeEnd = 0.33;
        [self.layer addSublayer:shapeLayer];
    }
    return self;
}

-(void)startAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = NO;
        [self.layer removeAnimationForKey:animationKey];
        //自旋动画
        CABasicAnimation *viewAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        viewAnimation.toValue = @(-M_PI * 2);
        viewAnimation.duration = 0.8;
        viewAnimation.repeatCount = MAXFLOAT;
        viewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
        [self.layer addAnimation:viewAnimation forKey:animationKey];
    });
}

-(void)stopAnimation
{
    self.hidden = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.layer removeAllAnimations];
    });
}

@end
