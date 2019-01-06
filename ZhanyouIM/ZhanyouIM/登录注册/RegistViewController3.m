//
//  RegistViewController3.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/15.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "RegistViewController3.h"
#import "AfficheViewController.h"
#import "DataService.h"




@interface RegistViewController3 ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSMutableDictionary * imgUrlDic;
}

@end

@implementation RegistViewController3

static long btnTag = 1;

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    imgUrlDic = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (IBAction)getImgBtnAction:(UIButton *)sender {
    
    btnTag = sender.tag;
    
    UIAlertController*alertyController=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction*xiangceAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dakaixiangce:YES];
    }];
    UIAlertAction*xiangjiAction=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dakaixiangce:NO];
    }];
    UIAlertAction*quxiaoAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertyController addAction:xiangceAction];
    [alertyController addAction:xiangjiAction];
    [alertyController addAction:quxiaoAction];
    [self presentViewController:alertyController animated:YES completion:nil];
    
}

-(void)dakaixiangce:(BOOL)xiangce{
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    /*
     //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
     //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
     //获取方方式3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
     */
    if (xiangce) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            NSLog(@"未开启相册访问");
            return;
        }
    }else{
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"未获得相机权限");
            return;
        }
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (xiangce) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    picker.allowsEditing = NO;
    picker.delegate = self;
    picker.navigationBar.barTintColor = [UIColor blackColor];
    [picker.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:20.0],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    //拿到图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //图片保存到本程序沙盒
    NSString *path_document = NSHomeDirectory();
    NSString *imagePathStr = [path_document stringByAppendingString:@"/Documents/touxiang.jpg"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePathStr atomically:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSArray *imageArray = @[image];
    if (btnTag == 1) {
        NSDictionary * paramDic = @{@"imageArray":imageArray,@"fileName":@"card.jpg"};
        [DataService requestWithUploadImageUrl:@"/api/upload/upload" params:paramDic block:^(id result) {
            if (result) {
                NSLog(@"result");
                [self->imgUrlDic setObject:[[result objectForKey:@"data"]objectAtIndex:0] forKey:@"informationUrl"];
                self.informationImgView.image = image;
            }
        }];
    }else{
        NSDictionary * paramDic = @{@"imageArray":imageArray,@"fileName":@"card.jpg"};
        [DataService requestWithUploadImageUrl:@"/api/upload/upload" params:paramDic block:^(id result) {
            if (result) {
                NSLog(@"result");
                [self->imgUrlDic setObject:[[result objectForKey:@"data"]objectAtIndex:0] forKey:@"personalUrl"];
                self.personalImgView.image = image;
            }
        }];
    }
}


- (IBAction)nextBtnAction:(UIButton *)sender {
    
    if ([imgUrlDic isKindOfClass:[NSNull class]]) {
        [self showTextMessage:@"请选择完善资料"];
        return;
    }else if ([imgUrlDic objectForKey:@"personalUrl"] == nil) {
        [self showTextMessage:@"请选择退伍资料证"];
        return;
    }else if ([imgUrlDic objectForKey:@"informationUrl"] == nil) {
        [self showTextMessage:@"请选择个人近照"];
        return;
    }
    
    NSDictionary * paramDic = @{@"uid":@"3",@"card_url":[imgUrlDic objectForKey:@"personalUrl"],@"head_url":[imgUrlDic objectForKey:@"informationUrl"]};
    
    [DataService requestWithPostUrl:@"/api/login/saveIcon" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            if (self->_returnToSession) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                AfficheViewController * affiche = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"affiche"];
                [self.navigationController pushViewController:affiche animated:YES];
            }
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
