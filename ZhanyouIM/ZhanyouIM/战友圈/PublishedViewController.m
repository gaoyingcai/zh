//
//  PublishedViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/30.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "PublishedViewController.h"
#import "DataService.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreLocation/CoreLocation.h>
#import "NIMLocationViewController.h"
#import "MMImageListView.h"



@interface PublishedViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>{
    float width;
    NSMutableArray *sourceArray;
    NSMutableArray *resultArray;
    BOOL isVideo;
    BOOL pushData;
}
//@property (nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic,strong)CLGeocoder *geocoder;
@property (strong, nonatomic) CIDetector *detector;
@property (nonatomic,strong)AVPlayerViewController * PlayerVC;
@end

@implementation PublishedViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    switch ([_moduleType intValue]) {
        case 1:
            self.title = @"新闻事实";
            break;
        case 2:
            self.title = @"创业";
            break;
        case 3:
            self.title = @"求助";
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    width = (k_screen_width-40)/3;
    [UIView animateWithDuration:0.3 animations:^{
        self.photoViewHeight.constant = k_screen_width/3;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    self.imgArray = [NSMutableArray arrayWithCapacity:0];
    [self setButton];
    sourceArray = [NSMutableArray arrayWithCapacity:0];
    
    if ([_moduleType intValue] == 3) {
        _textView.text = @"发布求助内容";
    }
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tianjia@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addMoment)];
    
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(sendData)];
    
}

-(void)sendData{
    
    [self showHUD:nil];
//    if (self.imgArray.count>0 && [self.imgArray[0] isKindOfClass:[NSDictionary class]]) {
    if (self.imgArray.count>0 && isVideo) {
    
        resultArray = [NSMutableArray arrayWithCapacity:0];
        
        //视频
        NSDictionary * paramDic1 =@{@"videoPath":[[self.imgArray objectAtIndex:0] objectForKey:@"path_source"]};
        [DataService requestWithUploadVideoUrl:@"/api/upload/upload" params:paramDic1 block:^(id result) {
            if ([self checkout:result]) {
                NSLog(@"%@",result);
                [self->resultArray addObject:[result objectForKey:@"data"]];
//                [self published:[result objectForKey:@"data"] s_type:@"2"];
                [self published:self->resultArray s_type:@"2"];
            }

        }];
        
        //图片
        NSDictionary * paramDic2 =@{@"imageArray":@[[[self.imgArray objectAtIndex:0] objectForKey:@"path_source_img_local"]],@"fileName":@"file"};
        [DataService requestWithUploadImageUrl:@"/api/upload/upload" params:paramDic2 block:^(id result) {
            if ([self checkout:result]) {
                NSLog(@"%@",result);
                [self->resultArray addObject:[result objectForKey:@"data"]];
//                [self published:[result objectForKey:@"data"] s_type:@"2"];
                [self published:self->resultArray s_type:@"2"];
            }
        }];
    }else if(self.imgArray.count>0){
        NSMutableArray * dataArray = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in self.imgArray) {
            [dataArray addObject:[dic objectForKey:@"local_img"]];
        }
        //图片
        NSDictionary * paramDic1 =@{@"imageArray":dataArray,@"fileName":@"file"};
        [DataService requestWithUploadImageUrl:@"/api/upload/upload" params:paramDic1 block:^(id result) {
            if ([self checkout:result]) {
                NSLog(@"%@",result);
                [self published:[result objectForKey:@"data"] s_type:@"1"];
            }
        }];
    }else if([_textView.text isEqualToString:@"发表您的动态..."]||_textView.text.length<1 ||[_textView.text isEqualToString:@"发表您的动态..."]){
        [self showTextMessage:@"请输入或选择发表内容"];
    }
    else{
        [self published:nil s_type:@"0"];
    }
    
}
//s_type  0,纯文字  1,图片   2,视频
-(void)published:(NSMutableArray*)imagePathArray s_type:(NSString*)s_type{
    if ([_textView.text isEqualToString:@"发表您的动态..."]) {
        _textView.text = @"";
    }
    NSString * finalStr = @"";
    if ([s_type isEqualToString:@"2"]&&imagePathArray.count<2) {
        return;
    }
    if (imagePathArray.count) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:imagePathArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString * replaceStr = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
        finalStr = [replaceStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    NSString * uid =[[self getUserinfo] objectForKey:@"uid"];
    NSDictionary *paramDic = @{@"uid":uid
                                ,@"content":_textView.text
                                ,@"type":_moduleType
                                ,@"s_type":s_type
                                ,@"source":finalStr
                               ,@"location":self.locationLabel.text
                                };
    [DataService requestWithPostUrl:@"/api/trend/publish" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self hideHUD];
            self->pushData = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
//设置添加按钮
-(void)setButton
{
    
    self.btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn setImage:[UIImage imageNamed:@"图片视频@2x.png"] forState:UIControlStateNormal];
    [self.btn.imageView setContentMode:UIViewContentModeScaleToFill];
    self.btn.frame=CGRectMake((self.imgArray.count%3)*width+20, self.imgArray.count/3*width+10, width-5, width-5);
    [self.btn addTarget:self action:@selector(ClickBtnImg) forControlEvents:UIControlEventTouchUpInside];
    [self.photoView addSubview:self.btn];

}
//添加按钮，按钮的点击事件
-(void)ClickBtnImg
{
    if (self.imgArray.count == 9) {
        [self showTextMessage:@"最多发布九张图片"];
    }else{
        NSLog(@"添加图片");
        UIAlertController*alertyController=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
        if (self.imgArray.count>0 && !isVideo) {
            UIAlertAction*xiangjiAction=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dakaixiangce:NO luzhi:NO];
            }];
            [alertyController addAction:xiangjiAction];
            
            UIAlertAction*xiangceAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dakaixiangce:YES luzhi:NO];
            }];
            [alertyController addAction:xiangceAction];
        }else{
            UIAlertAction*xiangjiAction=[UIAlertAction actionWithTitle:@"拍照/录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dakaixiangce:NO luzhi:YES];
            }];
            [alertyController addAction:xiangjiAction];
            
            UIAlertAction*xiangceAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dakaixiangce:YES luzhi:YES];
            }];
            [alertyController addAction:xiangceAction];
        }
        
        //    UIAlertAction*startVideoAction=[UIAlertAction actionWithTitle:@"录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        [self dakaixiangce:NO];
        //    }];
        UIAlertAction*quxiaoAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertyController addAction:quxiaoAction];
        //    [alertyController addAction:startVideoAction];
        [self presentViewController:alertyController animated:YES completion:nil];
    }
    
    
    
}
//录制视频
//- (void)startvideo
//{
//    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
//    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
//    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
//    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
//    [self presentViewController:ipc animated:YES completion:nil];
//    ipc.videoMaximumDuration = 10.0f;//30秒
//    ipc.delegate = self;//设置委托
//
//}

-(void)dakaixiangce:(BOOL)xiangce luzhi:(BOOL)luzhi{
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
    if (xiangce) {
        if (luzhi) {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//            picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
            picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
        }else{
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
        }
    }else if(luzhi){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie",@"public.image", nil];
        picker.videoMaximumDuration = 10.0f;//30秒
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
    }

    picker.delegate = self;
    picker.navigationBar.barTintColor = [UIColor blackColor];
    [picker.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:20.0],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.allowsEditing = NO;
    //画质类别
    picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentViewController:picker animated:YES completion:nil];
    
    
    //    //隐藏系统自带UI
    //    picker.showsCameraControls = YES;
    //    //设置摄像头
    ////    [self switchCameraIsFront:NO];
    //    //设置视频画质类别
    //    picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //    //设置散光灯类型
    //    picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    //    //设置录制的最大时长
    //    picker.videoMaximumDuration = 10;
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@",info);
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        //拿到图片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //图片保存到本程序沙盒
        NSString *imagePathStr = [NSHomeDirectory() stringByAppendingString:@"/Documents/touxiang.jpg"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePathStr atomically:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.imgArray addObject:@{@"local_img":image}];
        self->isVideo = NO;
//        [self.imgArray addObject:image];
        [self setFrame];
    }else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]){
        
        if (self.imgArray.count) {
            [self.imgArray removeAllObjects];
        }
        
        NSString *mediaName = [self getVideoNameBaseCurrentTime];
        NSLog(@"mediaName: %@", mediaName);
        NSData *data = [NSData dataWithContentsOfFile:info[UIImagePickerControllerMediaURL]];
        NSLog(@"%lu",(unsigned long)data.length);
        
        [self YS_saveVideoFromPath:info[UIImagePickerControllerMediaURL] toCachePath:[NSTemporaryDirectory() stringByAppendingPathComponent:mediaName]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//添加图片之后按钮移动
-(void)setFrame
{
    MMImageListView *imageListView = [[MMImageListView alloc] initWithFrame:CGRectZero];
    Moment *moment = [[Moment alloc] init];
    moment.fileCount = self.imgArray.count;
    moment.imageArray = self.imgArray;
    imageListView.moment = moment;
    CGFloat top = 0;
    if (moment.fileCount > 0) {
        imageListView.origin = CGPointMake(15, top);
        top = imageListView.bottom + 8;
    }
    [self.photoView addSubview:imageListView];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.imgArray.count%3 ==0 && self.imgArray.count >=3 && self.imgArray.count <9) {
            self.photoViewHeight.constant = top +self->width;
        }else{
            self.photoViewHeight.constant = top;
        }
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    
    if (isVideo || self.imgArray.count >8) {
        _btn.hidden = YES;
    }else{
        _btn.hidden = NO;
    }
    
    self.btn.frame=CGRectMake((self.imgArray.count%3)*width+20, self.imgArray.count/3*width+10, width-5, width-5);
    [self.photoView bringSubviewToFront:self.btn];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@"发表您的动态..."]||[self.textView.text isEqualToString:@"发布求助内容"]) {
        textView.text=@"";
        _textView.textColor = [UIColor blackColor];
    }
    return YES;
}

//以当前时间合成视频名称
- (NSString *)getVideoNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".MOV"];
//    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".mp4"];
}
- (void)YS_saveVideoFromPath:(NSURL *)videoPath toCachePath:(NSString *)path{
    
    //转码配置
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = [NSURL fileURLWithPath:path];
    exportSession.outputFileType = AVFileTypeMPEG4;
    NSLog(@"videoPath == %@",videoPath);
    NSLog(@"path == %@",path);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;
        switch (exportStatus)
        {
            case AVAssetExportSessionStatusFailed:
            {
                // log error to text view
                NSError *exportError = exportSession.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                NSData *data = [NSData dataWithContentsOfFile:path];
                NSLog(@"%lu",(unsigned long)data.length);
                NSLog(@"转码成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    // UI更新代码
                    
                    //拿到图片
                    UIImage *image = [self getVideoPreViewImageWithPath:videoPath];
                    //图片保存到本程序沙盒
                    NSString *imagePathStr = [NSHomeDirectory() stringByAppendingString:@"/Documents/suolue.jpg"];
                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePathStr atomically:YES];
                    [self.imgArray addObject:@{@"path_source":path,@"path_source_img_local":image}];
                    self->isVideo = YES;
                    [self setFrame];
                });
            }
        }
    }];
}

//获取视频的第一帧截图, 返回UIImage
//需要导入AVFoundation.h
//获取视频的第一帧返回y图片
- (UIImage*) getVideoPreViewImageWithPath:(NSURL *)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time= CMTimeMakeWithSeconds(0.0, 600);
    NSError *error= nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img= [[UIImage alloc] initWithCGImage:image];
    return img;
}

//设置前置或者后置摄像头
//- (void)switchCameraIsFront:(BOOL)front
//{
//    if (front) {
//        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
//            [self setCameraDevice:UIImagePickerControllerCameraDeviceFront];
//
//        }
//    } else {
//        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
//            [self setCameraDevice:UIImagePickerControllerCameraDeviceRear];
//
//        }
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)locationBtnAction:(id)sender {
    
    NIMLocationViewController *locationController = [[NIMLocationViewController alloc] initWithNibName:nil bundle:nil];
    locationController.business = @"定位";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(value:) name:@"GET_LOCATION_TITLE" object:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:locationController];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    
}


-(void)value:(NSNotification*)sender{
    NSLog(@"%@",sender.userInfo);
    self.locationLabel.text = [sender.userInfo objectForKey:@"location"];
    //注意关闭通知，否则下次监听还会收到这次的通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)viewWillDisappear:(BOOL)animated{
    if (pushData) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"QZ" object:nil userInfo:@{@"type":[NSString stringWithFormat:@"%@",_moduleType]}];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textView resignFirstResponder];
}
@end
