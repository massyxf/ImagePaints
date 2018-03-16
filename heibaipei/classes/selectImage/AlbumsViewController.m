//
//  AlbumsViewController.m
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "AlbumsViewController.h"
#import "YPKManager.h"
#import "YPKImageModel.h"
#import "YPKAlbumModel.h"
#import "YPKImageCell.h"
#import "YPKImageViewController.h"
#import "TAImageBrowserHud.h"
#import "YPKAlbumCell.h"
#import "PhotoDemosCell.h"
#import "AddImgViewModel.h"
#import "UIButton+YXFExtension.h"
#import "YPKImagesViewController.h"
#import "YPKImageViewController.h"
#import "YPKImageModel.h"

#define PhotoDemosCellId @"PhotoDemosCellId"
#define YPKAlbumCellId @"YPKAlbumCellId"

@interface AlbumsViewController ()<UITableViewDelegate,UITableViewDataSource>

/*table*/
@property (nonatomic,weak)UITableView *albumsTableView;

/*是否已授权访问相册*/
@property (nonatomic,assign)BOOL authed;

/*albums*/
@property (nonatomic,strong)NSMutableArray<YPKAlbumModel *> *albums;

/*hub*/
@property (nonatomic,weak)TAImageBrowserHud *hud;

/*viewmodel*/
@property (nonatomic,strong)AddImgViewModel *model;

@end

@implementation AlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"选择图片";
    UITableView *albumsView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:albumsView];
    albumsView.delegate = self;
    albumsView.dataSource = self;
    [albumsView registerClass:[PhotoDemosCell class] forCellReuseIdentifier:PhotoDemosCellId];
    [albumsView registerClass:[YPKAlbumCell class] forCellReuseIdentifier:YPKAlbumCellId];
    _albumsTableView = albumsView;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    _authed = status == PHAuthorizationStatusAuthorized;
    
    if (!_authed) {
        UIButton *bottomBtn = [UIButton customBtnWithTarget:self action:@selector(addImg:)];
        bottomBtn.frame = CGRectMake(0, 0, 0, 40);
        [albumsView setTableFooterView:bottomBtn];
        [bottomBtn setTitle:@"添加图片" forState:UIControlStateNormal];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"拍照" style:UIBarButtonItemStyleDone target:self action:@selector(camera:)];
        [self loadData];
    }
    
    TAImageBrowserHud *hud = [[TAImageBrowserHud alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    hud.center = CGPointMake(HBPSCREENW / 2.0, HBPSCREENH / 2.0);
    [self.view addSubview:hud];
    hud.hidden = YES;
    _hud = hud;
}

-(void)loadData{
    [_hud startAnimation];
    YPKWeakSelf;
    [YPKManager getAllAlbums:^(NSArray<YPKAlbumModel *> *collections, NSError *error) {
        NSMutableArray *resultAlbums = [collections mutableCopy];
        [collections enumerateObjectsUsingBlock:^(YPKAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.count == 0) {
                [resultAlbums removeObject:obj];
            }
        }];
        [weakSelf.albumsTableView setTableFooterView:[UIView new]];
        weakSelf.albums = resultAlbums;
        [weakSelf.albumsTableView reloadData];
        [weakSelf.hud stopAnimation];
    }];
}

#pragma mark - getter
-(NSMutableArray<YPKAlbumModel *> *)albums{
    if (!_albums) {
        _albums = [NSMutableArray array];
    }
    return _albums;
}

-(AddImgViewModel *)model{
    if (!_model) {
        _model = [AddImgViewModel initWithVc:self];
    }
    return _model;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albums.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:PhotoDemosCellId forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:YPKAlbumCellId forIndexPath:indexPath];
        YPKAlbumCell *albumCell = (YPKAlbumCell *)cell;
        albumCell.album = self.albums[indexPath.row - 1];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 80;
    }
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *toVc = nil;
    if (indexPath.row > 0) {
        YPKAlbumModel *model = self.albums[indexPath.row-1];
        YPKImagesViewController *imgsVc = [YPKImagesViewController initWithAlbum:model];
        toVc = imgsVc;
    }else{
        YPKImageViewController *imgVc = [[YPKImageViewController alloc] init];
        NSMutableArray *images = [NSMutableArray array];
        for (int i=1; i<=6; i++) {
            NSString *img = [NSString stringWithFormat:@"%zd.png",i];
            UIImage *image = [UIImage imageNamed:img];
            YPKImageModel *model = [[YPKImageModel alloc] initWithAsset:nil image:image info:nil];
            model.isAppPic = YES;
            [images addObject:model];
        }
        imgVc.images = [NSArray arrayWithArray:images];
        imgVc.currentIndex = 0;
        toVc = imgVc;
    }
    
    [self.navigationController pushViewController:toVc animated:YES];
}

#pragma mark - action
-(IBAction)addImg:(id)sender{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"添加图片" message:@"添加的图片将会被处理成黑白照之后添加到本程序，原图片不变。" preferredStyle:UIAlertControllerStyleActionSheet];
    YPKWeakSelf;
    UIAlertAction *imgAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [weakSelf loadData];
            }
        }];
    }];
    [alertVc addAction:imgAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVc addAction:cancelAction];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

-(IBAction)camera:(id)sender{
    [self.model startCameraCompletion:^(UIImage *img) {
        NSLog(@"---%@---",img);
    }];
}

@end
