//
//  PhotoDemosCell.m
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "PhotoDemosCell.h"
#import <Masonry/Masonry.h>
#import "UIButton+YXFExtension.h"

@interface PhotoDemosCell ()

/*title*/
@property (nonatomic,weak)UILabel *titleLabel;

/*image1*/
@property (nonatomic,weak)UIButton *img1Btn;

/*image2*/
@property (nonatomic,weak)UIButton *img2Btn;


@end

@implementation PhotoDemosCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

-(void)setupUI{
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    _titleLabel = titleLabel;
    titleLabel.text = @"示例图片";
    
    UIButton *btn1 = [UIButton customBtnWithTarget:self action:@selector(tapImg:)];
    [self.contentView addSubview:btn1];
    [btn1 setImage:[UIImage imageNamed:@"1.png"] forState:UIControlStateNormal];
    _img1Btn = btn1;
    
    UIButton *btn2 = [UIButton customBtnWithTarget:self action:@selector(tapImg:)];
    [self.contentView addSubview:btn2];
    [btn2 setImage:[UIImage imageNamed:@"2.png"] forState:UIControlStateNormal];
    _img2Btn = btn2;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(30);
        make.leading.mas_equalTo(self.contentView).offset(10);
    }];
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.mas_equalTo(btn1);
        make.leading.equalTo(btn1.mas_trailing).offset(20);
    }];
}

-(IBAction)tapImg:(UIButton *)sender{
    if (self.tapImg) {
        self.tapImg(@"1.png");
    }
}

@end
