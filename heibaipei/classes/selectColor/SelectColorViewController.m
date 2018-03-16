//
//  SelectColorViewController.m
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "SelectColorViewController.h"
#import <Masonry/Masonry.h>

@interface SelectColorViewController ()

/*color image*/
@property (nonatomic,weak)UIImageView *colorImageView;

/*current color*/
@property (nonatomic,weak)UIView *currentColorView;

@end

@implementation SelectColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"选择颜色";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(confirm:)];
    
    [self setupUI];
}

-(void)setupUI{
    UIImageView *imgView = [[UIImageView alloc] init];
    [self.view addSubview:imgView];
    imgView.image = [UIImage imageNamed:@"pickerColor.png"];
    _colorImageView = imgView;
    
    UIView *currentView = [[UIView alloc] init];
    [self.view addSubview:currentView];
    currentView.backgroundColor = self.originColor;
    _currentColorView = currentView;
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).offset(20);
        make.width.height.mas_equalTo(HBPSCREENW - 40);
    }];
    
    [currentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(self.view).offset(64 + 20);
        make.width.height.mas_equalTo(40);
    }];
}

#pragma mark - action
-(IBAction)confirm:(id)sender{
    UIColor *selectColor = self.currentColorView.backgroundColor;
    NSLog(@"%@",selectColor);
    if (selectColor != nil && selectColor != _originColor && [self.delegate respondsToSelector:@selector(selectVc:selectColor:)]) {
        [self.delegate selectVc:self selectColor:selectColor];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 点击结束
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    // tap点击的位置
    CGPoint point = [touch locationInView:self.colorImageView];
    //调用自定义方法,从【点】中取颜色
    UIColor *selectedColor = [self colorAtPixel:point];
    
    _currentColorView.backgroundColor = selectedColor;
}
- (UIColor *)colorAtPixel:(CGPoint)point {
    // 判断是否点击在这个点上
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.colorImageView.frame.size.width, self.colorImageView.frame.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.colorImageView.image.CGImage;
    NSUInteger width = self.colorImageView.frame.size.width;
    NSUInteger height = self.colorImageView.frame.size.height;
    //创建色彩空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    //颜色转换
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    //绘图
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // 获取颜色值
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@end
