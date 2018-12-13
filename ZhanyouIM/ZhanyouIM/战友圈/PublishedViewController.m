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
#import <CoreLocation/CoreLocation.h>


#define VIDEOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoCache"]



@interface PublishedViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,CLLocationManagerDelegate>{
    float width;
    NSMutableArray *sourceArray;

}
@property (nonatomic, strong) CLLocationManager* locationManager;
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
    
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tianjia@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addMoment)];
    
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(sendData)];
    
}

-(void)sendData{
    
    
    
    if (self.imgArray.count>0 && [self.imgArray[0] isKindOfClass:[NSDictionary class]]) {
        //视频
        NSDictionary * paramDic1 =@{@"videoPath":[[self.imgArray objectAtIndex:0] objectForKey:@"path"]};
        [DataService requestWithUploadVideoUrl:@"/api/upload/upload" params:paramDic1 block:^(id result) {
            if (result) {
                NSLog(@"%@",result);
                [self published:[result objectForKey:@"data"] s_type:@"2"];
            }

        }];
    }else if(self.imgArray.count>0){
        //图片
        NSDictionary * paramDic1 =@{@"imageArray":self.imgArray,@"fileName":@"file"};
        [DataService requestWithUploadImageUrl:@"/api/upload/upload" params:paramDic1 block:^(id result) {
            if (result) {
                NSLog(@"%@",result);
                [self published:[result objectForKey:@"data"] s_type:@"1"];
            }
        }];
    }else{
        [self published:nil s_type:@"0"];
    }
    
}
//s_type  0,纯文字  1,图片   2,视频
-(void)published:(NSMutableArray*)imagePathArray s_type:(NSString*)s_type{
    if ([_textView.text isEqualToString:@"发表您的动态..."]) {
        _textView.text = @"";
    }
    NSString * finalStr = @"";
    if (imagePathArray.count) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:imagePathArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString * replaceStr = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
        finalStr = [replaceStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    NSString * uid =[[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user]objectForKey:@"uid"];
    NSDictionary *paramDic = @{@"uid":uid
                                ,@"content":_textView.text
                                ,@"type":_moduleType
                                ,@"s_type":s_type
                                ,@"source":finalStr
                               ,@"location":self.locationLabel.text
                                };
    [DataService requestWithPostUrl:@"/api/trend/publish" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
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
    NSLog(@"添加图片");
    UIAlertController*alertyController=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction*xiangceAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dakaixiangce:YES];
    }];
    UIAlertAction*xiangjiAction=[UIAlertAction actionWithTitle:@"拍照/录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dakaixiangce:NO];
    }];
//    UIAlertAction*startVideoAction=[UIAlertAction actionWithTitle:@"录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self dakaixiangce:NO];
//    }];
    UIAlertAction*quxiaoAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertyController addAction:xiangceAction];
    [alertyController addAction:xiangjiAction];
    [alertyController addAction:quxiaoAction];
//    [alertyController addAction:startVideoAction];
    [self presentViewController:alertyController animated:YES completion:nil];
    
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
    
    if (xiangce) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie",@"public.image", nil];
        picker.videoMaximumDuration = 10.0f;//30秒
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
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        //拿到图片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //图片保存到本程序沙盒
        NSString *imagePathStr = [NSHomeDirectory() stringByAppendingString:@"/Documents/touxiang.jpg"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePathStr atomically:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.imgArray addObject:image];
        [self setFrame];
    }else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]){
        
        if (self.imgArray.count) {
            [self.imgArray removeAllObjects];
        }
        
        NSString *mediaName = [self getVideoNameBaseCurrentTime];
        NSLog(@"mediaName: %@", mediaName);
        [self saveVideoFromPath:info[UIImagePickerControllerMediaURL] toCachePath:[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName]];
        [self dismissViewControllerAnimated:YES completion:nil];
        
//        NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
//        [self.imgArray addObject:@{@"url":url,@"path":[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName]}];
        
        [self.imgArray addObject:@{@"path":[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName]}];
        
        [self setFrame];
        
        //获取封面
//        UIImage *image =  [self getVideoPreViewImageWithPath:url];
//        [self.imgArray addObject:image];
//        [self setFrame];
    }

}
//添加图片之后按钮移动
-(void)setFrame
{
    static int num_rows = 1;
    if (self.imgArray.count<=2) {
        num_rows = 1;
    }else if (self.imgArray.count>2 && self.imgArray.count<=5) {
        num_rows = 2;
    }else{
        num_rows = 3;
    }
    
    if (self.imgArray.count>0 && [self.imgArray[0] isKindOfClass:[NSDictionary class]]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.photoViewHeight.constant = k_screen_width*2/3;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
            
        self.btn.hidden = YES;
        _PlayerVC = [[AVPlayerViewController alloc] init];
        _PlayerVC.view.backgroundColor = [UIColor lightGrayColor];
    
//        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[self.imgArray objectAtIndex:0] objectForKey:@"url"]];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[[self.imgArray objectAtIndex:0] objectForKey:@"path"]]];
        _PlayerVC.player = [AVPlayer playerWithPlayerItem:item];
        _PlayerVC.view.frame = CGRectMake(15, 15, k_screen_width*9/32, k_screen_width/2);
        _PlayerVC.showsPlaybackControls = YES;
        [self.photoView addSubview:_PlayerVC.view];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.photoViewHeight.constant = k_screen_width*num_rows/3;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        self.btn.frame=CGRectMake((self.imgArray.count%3)*width+20, self.imgArray.count/3*width+10, width-5, width-5);
        self.btn.hidden = NO;
        //显示所有的img
        for (int i = 0; i<self.imgArray.count; i++) {
            UIImageView *imgView=[[UIImageView alloc]init];
            imgView.frame=CGRectMake((i%3)*width+20, i/3*width+10, width-5, width-5);
            imgView.image=[self.imgArray objectAtIndex:i];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.layer.masksToBounds = YES;
            
            [self.photoView addSubview:imgView];
        }
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@"发表您的动态..."]) {
        textView.text=@"";
        _textView.textColor = [UIColor blackColor];
    }
    return YES;
}

//以当前时间合成视频名称
- (NSString *)getVideoNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".MOV"];
}
//将视频保存到缓存路径中
- (void)saveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEOCACHEPATH]) {
        
        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:VIDEOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {
        
        NSLog(@"路径存在");
    }
    
    NSError *error;
    [fileManager copyItemAtPath:videoPath toPath:path error:&error];
    if (error) {
        
        NSLog(@"文件保存到缓存失败");
    }
}

//获取视频的第一帧截图, 返回UIImage
//需要导入AVFoundation.h
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
    
    NSLog(@"%d",[CLLocationManager locationServicesEnabled]);
    NSLog(@"%d",[CLLocationManager locationServicesEnabled]);
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 3、请求定位授权
        // 请求在使用期间授权（弹框提示用户是否允许在使用期间定位）,需添加NSLocationWhenInUseUsageDescription到info.plist
        [_locationManager requestWhenInUseAuthorization];
        // 请求在后台定位授权（弹框提示用户是否允许不在使用App时仍然定位）,需添加NSLocationAlwaysUsageDescription添加key到info.plist
        [_locationManager requestAlwaysAuthorization];
        // 4、设置定位精度
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 5、设置定位频率，每隔多少米定位一次
        _locationManager.distanceFilter = 10.0;
        // 6、设置代理
        _locationManager.delegate = self;
        // 7、开始定位
        // 注意：开始定位比较耗电，不需要定位的时候最好调用 [stopUpdatingLocation] 结束定位。
        [_locationManager startUpdatingLocation];
    }else{
        // 弹框提示
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请打开允许定位!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}
#pragma mark - CLLocationManagerDelegate methods

// 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error.localizedDescription);
}

// 位置更新
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 获取最新定位
    CLLocation *location = locations.lastObject;
    // 打印位置信息
    NSLog(@"精度：%.2f, 纬度：%.2f", location.coordinate.latitude, location.coordinate.longitude);
    
    if (_geocoder==nil) {
        _geocoder=[[CLGeocoder alloc]init];
    }
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark=[placemarks firstObject];
        
        //        NSLog(@"详细信息:%@",placemark.addressDictionary);
        NSLog(@"位置信息:%@",placemark.name);
        NSLog(@"街道:%@",placemark.thoroughfare);
        NSLog(@"城市:%@",placemark.locality);
        NSLog(@"区县:%@",placemark.subLocality);
        NSLog(@"省份:%@",placemark.administrativeArea);
        NSLog(@"国家:%@",placemark.country);
        
        self.locationLabel.text = [NSString stringWithFormat:@"%@%@%@",placemark.locality,placemark.subLocality,placemark.name];
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:placemark.subLocality message:placemark.thoroughfare preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
//        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    
    // 停止定位
    [_locationManager stopUpdatingLocation];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textView resignFirstResponder];
}
@end
