//
//  ViewController.m
//  DemoPhotoKit
//
//  Created by yxf on 2017/6/12.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YPKImagesViewController.h"
#import "YPKManager.h"
#import "YPKImageModel.h"
#import "YPKAlbumModel.h"
#import "YPKImageCell.h"
#import "YPKImageViewController.h"

@interface YPKImagesViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

/** image collection*/
@property(nonatomic,weak)UICollectionView *collectionView;

/** photos*/
@property(nonatomic,strong)NSMutableArray *images;

/** album*/
@property(nonatomic,strong)YPKAlbumModel *album;

@end

@implementation YPKImagesViewController

+(instancetype)initWithAlbum:(YPKAlbumModel *)album{
    YPKImagesViewController *vc = [[YPKImagesViewController alloc] init];
    if (vc) {
        vc.album = album;
    }
    return vc;
}

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
    self.navigationItem.title = self.album.album.localizedTitle ? self.album.album.localizedTitle : @"我的相册";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat length = (SCREENWIDTH - 20) / 3.0;
    layout.itemSize = CGSizeMake(length, length);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    UICollectionView *collectionview = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:layout];
    collectionview.backgroundColor = [UIColor whiteColor];
    collectionview.delegate = self;
    collectionview.dataSource = self;
    [collectionview registerClass:[YPKImageCell class] forCellWithReuseIdentifier:ImageCellIdentifier];
    [self.view addSubview:collectionview];
    _collectionView = collectionview;
    [self.view bringSubviewToFront:self.indicatorView];
    if (self.album) {
        YPKWeakSelf;
        [YPKManager getAlbum:self.album completion:^(NSArray<YPKImageModel *> *images, NSError *error) {
            weakSelf.images = [images mutableCopy];
            [weakSelf.collectionView reloadData];
            [weakSelf.indicatorView stopAnimating];
        }];
    }
}


-(IBAction)cancel:(id)sender{
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionViewDelegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YPKImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier
                                                                   forIndexPath:indexPath];
    cell.model = self.images[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YPKImageViewController *vc = [[YPKImageViewController alloc] init];
    vc.images = self.images;
    vc.currentIndex = indexPath.item;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
