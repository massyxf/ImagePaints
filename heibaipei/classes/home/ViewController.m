//
//  ViewController.m
//  heibaipei
//
//  Created by yxf on 2018/3/12.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+YXFExtension.h"
#import "ImgScrollView.h"
#import <Masonry/Masonry.h>
#import "SelectColorViewController.h"
#import "AlbumsViewController.h"
#import "YXFColorTool.h"
#import "ColorConfig.h"

@interface ViewController ()<UINavigationControllerDelegate,SelectColorViewControllerDelegate>{
    UIScrollView *_bgScrollView;
    UIButton *_imgBtn;
    ImgScrollView *_imgView;
    UIButton *_colorBtn;
    UIView *_currentColorView;
    UIButton *_lastColorBtn;
    UIButton *_nextColorBtn;
    UIButton *_saveBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏隐藏
    self.navigationController.delegate = self;
    
    [self setupUI];
    
    [self addNote];
}

#pragma mark - ui
-(void)setupUI{
    _bgScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_bgScrollView];
    _bgScrollView.contentSize = CGSizeZero;
    
    _imgBtn = [UIButton customBtnWithTarget:self action:@selector(selectImg:)];
    [_imgBtn setTitle:@"选择图片" forState:UIControlStateNormal];
    [_bgScrollView addSubview:_imgBtn];
    
    _lastColorBtn = [UIButton customBtnWithTarget:self action:@selector(lastColor:)];
    [_lastColorBtn setTitle:@"上一张" forState:UIControlStateNormal];
    [_bgScrollView addSubview:_lastColorBtn];
    
    _nextColorBtn = [UIButton customBtnWithTarget:self action:@selector(nextColor:)];
    [_nextColorBtn setTitle:@"下一张" forState:UIControlStateNormal];
    [_bgScrollView addSubview:_nextColorBtn];
    
    _colorBtn = [UIButton customBtnWithTarget:self action:@selector(selectColor:)];
    [_colorBtn setImage:[UIImage imageNamed:@"pickerColor"] forState:UIControlStateNormal];
    [_bgScrollView addSubview:_colorBtn];
    
    _saveBtn = [UIButton customBtnWithTarget:self action:@selector(saveImg:)];
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_bgScrollView addSubview:_saveBtn];
    
    _imgView = [[ImgScrollView alloc] init];
    [_bgScrollView addSubview:_imgView];
    
    _currentColorView = [[UIView alloc] init];
    [_bgScrollView addSubview:_currentColorView];
    _currentColorView.backgroundColor = [UIColor redColor];
    
    //约束
    [_bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.width.height.equalTo(self.view);
    }];
    
    [_imgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(30);
        make.top.equalTo(_bgScrollView.mas_bottom).offset(10);
    }];
    
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgBtn.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.view).offset(10);
        make.trailing.mas_equalTo(self.view).offset(-10);
        make.height.mas_equalTo(_imgView.mas_width).multipliedBy(1.0);
    }];
    
    [_colorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.height.mas_equalTo(60);
        make.top.equalTo(_imgView.mas_bottom).offset(10);
    }];
    
    [_currentColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_colorBtn);
        make.top.equalTo(_colorBtn.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(40, 10));
    }];
    
    [_lastColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_colorBtn);
        make.leading.mas_equalTo(self.view).offset(10);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    
    [_nextColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.with.height.equalTo(_lastColorBtn);
        make.trailing.mas_equalTo(self.view).offset(-10);
    }];
    
    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(60, 40));
        make.top.equalTo(_currentColorView.mas_bottom).offset(10);
    }];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _bgScrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(_saveBtn.frame) + 40);
}

-(void)dealloc{
    [self removeNote];
}

#pragma mark - action
-(IBAction)selectImg:(id)sender{
    AlbumsViewController *albumVc = [[AlbumsViewController alloc] init];
    [self.navigationController pushViewController:albumVc animated:YES];
}

-(IBAction)lastColor:(id)sender{
    
}

-(IBAction)nextColor:(id)sender{
    
}

-(IBAction)selectColor:(id)sender{
    SelectColorViewController *selectVc = [[SelectColorViewController alloc] init];
    selectVc.originColor = _currentColorView.backgroundColor;
    selectVc.delegate = self;
    [self.navigationController pushViewController:selectVc animated:YES];
}

-(IBAction)saveImg:(id)sender{
    
}

#pragma mark - SelectColorViewControllerDelegate
-(void)selectVc:(SelectColorViewController *)selectVc selectColor:(UIColor *)color{
    self->_currentColorView.backgroundColor = color;
    [ColorConfig shareInstance].currentColor = color;
}

#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated{
    BOOL isShow = (viewController == self);
    [self.navigationController setNavigationBarHidden:isShow animated:YES];
}

#pragma mark - note
-(void)addNote{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImg:) name:HBPNote_SelectImg object:nil];
}

-(void)removeNote{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)changeImg:(NSNotification *)note{
    UIImage *image = note.userInfo[@"image"];
    if (image) {
        self->_imgView.imgView.image = image;
        CGFloat width = CGRectGetWidth(_imgView.frame);
        CGFloat height = image.size.height / image.size.width * width;
        [_imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
        [self viewDidLayoutSubviews];
        _imgView.imgView.frame = CGRectMake(0, 0, width, height);
        _imgView.zoomScale = 1;
        [ColorConfig shareInstance].baseImg = image;
        [ColorConfig shareInstance].scaleRate = 1;
        [YXFColorTool shareInstance].revokePoints = nil;
    }
}


@end
