//
//  AddImgViewModel.m
//  heibaipei
//
//  Created by yxf on 2018/3/13.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "AddImgViewModel.h"


@interface AddImgViewModel ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

/*vc*/
@property (nonatomic,weak)UIViewController *superVc;

/*call back*/
@property (nonatomic,copy)CameraImgBlock imgBlock;

@end

@implementation AddImgViewModel

+(instancetype)initWithVc:(UIViewController *)vc{
    AddImgViewModel *model = [[AddImgViewModel alloc] init];
    model.superVc = vc;
    return model;
}

-(void)startCameraCompletion:(CameraImgBlock)completion{
    self.imgBlock = completion;
    /// 先判断摄像头硬件是否好用
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 用户是否允许摄像头使用
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        // 不允许弹出提示框
        if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
//            [RMUtils alertWithTitle:@"" message:@"摄像头访问受限,前往设置" delegate:self tag:10 cancelButtonTitle:@"取消" otherButtonTitles:@"设置"];
        }else{
            // 这里是摄像头可以使用的处理逻辑
            UIImagePickerController *imageVc = [[UIImagePickerController alloc] init];
            imageVc.delegate = self;
            imageVc.allowsEditing = YES;
            imageVc.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.superVc presentViewController:imageVc animated:YES completion:nil];
        }
    } else {
        // 硬件问题提示
//        [RMUtils showAlertControllerWithMessage:@"请检查手机摄像头设备" onViewController:self];
    }
}

#pragma mark - UINavigationControllerDelegate,UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *editedImg = info[UIImagePickerControllerEditedImage];
        if (editedImg && self.imgBlock) {
            self.imgBlock(editedImg);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
