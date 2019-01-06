//
//  BaseViewController.m
//  JuMin
//
//  Created by 管理员 on 2017/8/31.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "CommonCrypto/CommonDigest.h"


@interface BaseViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
{
    MBProgressHUD *_hud;//加载提示控件
    UIImageView * imageView; //缺省图片
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor=[UIColor whiteColor];
    
//    self.interactivePopGestureRecognizer.delegate = self;
//    self.delegate = self;

    self.navigationController.interactivePopGestureRecognizer.delegate =self;
    self.navigationController.delegate = self;
    
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title =@"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
//    self.navigationController.navigationBar.hidden=YES;
    [[self.navigationController.navigationBar subviews] objectAtIndex:0].alpha = 0;
    
    
}
#pragma mark - 滑动开始触发事件
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //只有导航的根控制器不需要右滑的返回的功能。
    NSLog(@"%@",self.navigationController.viewControllers);
    self.tabBarController.tabBar.hidden=YES;

    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    [self popoverPresentationController];

    return YES;
}

//-(void)setSlidBack{
//    //1.获取系统interactivePopGestureRecognizer对象的target对象
//    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
//
//    //2.创建滑动手势，taregt设置interactivePopGestureRecognizer的target，所以当界面滑动的时候就会自动调用target的action方法。
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
//    [pan addTarget:target action:NSSelectorFromString(@"swipeGesture:")];
//    pan.delegate = self;
//
//    //3.添加到导航控制器的视图上
//    [self.navigationController.view addGestureRecognizer:pan];
//
//    //4.禁用系统的滑动手势
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//}

//-(void)setRightBarButtonItem:(NSString*)imagName{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0, 0, 25, 25);
//    [btn setBackgroundImage:[UIImage imageNamed:imagName] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(setBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
//}

//-(void)setSlidBack{
//    //添加轻扫手势
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
//    //设置轻扫的方向
//    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight; //默认向右
//    [self.view addGestureRecognizer:swipeGesture];
//
//    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGesture:)];
//    swipeGesture2.direction = UISwipeGestureRecognizerDirectionDown;
//    [self.view addGestureRecognizer:swipeGesture2];
//
//}
////轻扫手势触发方法
//-(void)swipeGesture:(id)sender
//{
//
//    CATransition *animation = [CATransition animation];
//    animation.duration = 0.4;
////    animation.timingFunction = UIViewAnimationCurveEaseInOut;//开始和结束慢
//    animation.timingFunction = UIViewAnimatingPositionEnd;//开始和结束慢
//    animation.type = kCATransitionPush;   //推出效果
//    animation.subtype = kCATransitionFromLeft;
//    [self.view.window.layer addAnimation:animation forKey:nil];
//
//    [self.navigationController popViewControllerAnimated:YES];
//
//}
//判断登录状态
-(BOOL)isLogin{
    if ([[[[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"] objectForKey:@"login"]isEqualToString:@"1"])
    {
        return 1;
    }
    return 0;
}
//设置用户信息
-(void)setUserInfo:(NSMutableDictionary*)dic{
    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:@"userInfo"];
}
//返回用户信息
-(NSMutableDictionary*)getUserinfo{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
}
//显示hud加载提示
- (void)showHUD:(NSString *)title
{
    if (_hud == nil) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
//    _hud.labelText = title;
//    //有无灰色的遮罩视图
//    _hud.dimBackground = NO;
    
    _hud.label.text = title;
    //有无灰色的遮罩视图
//    _hud.dimBackground = NO;
}

//隐藏加载提示
- (void)hideHUD
{
    if (_hud) {
        [_hud removeFromSuperview];
    }
    _hud = nil;
}

// 显示文本提示
- (void)showTextMessage:(NSString *)message
{
    //显示文本提示
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //以屏幕中心为基点在x,y方向偏移量
//        hud.xOffset=0;
//        hud.yOffset=200;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.label.font = [UIFont boldSystemFontOfSize:16];
    
    //隐藏的时候从父试图中移除
    hud.removeFromSuperViewOnHide = YES;
    //加载时长
    [hud performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.0];
}
-(void)wangluojiance{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
//        // 当网络状态改变时调用
//        switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//                NSLog(@"未知网络");
//                [self showTextMessage:@"未知网络"];
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//                NSLog(@"没有网络");
//                [self showTextMessage:@"请检查网络设置"];
//                break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                NSLog(@"移动网络");
//                [self showTextMessage:@"移动网络"];
//                break;
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                NSLog(@"WIFI");
//                [self showTextMessage:@"WIFI"];
//                break;
//        }
//        if (status!=3) {
        if (status==0) {
            UIAlertController*alertController=[UIAlertController alertControllerWithTitle:@"提示" message:@"请检查网络设置" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    //开始监控
    [manager startMonitoring];
    
}
/*密码验证 */
-(BOOL)isValidatePassword:(NSString *)password{
        
    if (password.length>=8&&password.length<=16) {

        NSString *passwordRegex =@"^[a-z0－9A-Z]*$";
        NSPredicate *passwordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex];
        if ([passwordPredicate evaluateWithObject:password]) {
            NSString *numberRegex = @"^[0-9]*$";
            NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",numberRegex];
            NSString *letterRegex = @"^[a-zA-Z]*$";
            NSPredicate *letterPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",letterRegex];
            if ([numberPredicate evaluateWithObject:password]) {
                return NO;
            }else if ([letterPredicate evaluateWithObject:password]){
                return NO;
            }else{
                return YES;
            }
        }else{
            return NO;
        }
    }
    return NO;
    
    
}
/*手机号码验证*/
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-9])|(17[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}
//身份证号
- (BOOL)isValidateIdentityCard:(NSString *)IDCardNumber
{
    if (IDCardNumber.length == 15) {
        //|  地址  |   年    |   月    |   日    |
        NSString *regex = @"^(\\d{6})([3-9][0-9][01][0-9][0-3])(\\d{4})$";
        NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        return [identityCardPredicate evaluateWithObject:IDCardNumber];
    } else if (IDCardNumber.length == 18) {
        //|  地址  |      年       |   月    |   日    |
        NSString *regex = @"^(\\d{6})([12][019][0-9][0-9][01][0-9][0-3])(\\d{4})(\\d|[xX])$";
        NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
//        return [identityCardPredicate evaluateWithObject:IDCardNumber];
        if ([identityCardPredicate evaluateWithObject:IDCardNumber]) {
            return [self isCorrect:IDCardNumber];
        }else{
            return NO;
        }
    } else {
        return NO;
    }
}
- (BOOL)isCorrect:(NSString *)IDNumber
{
    NSMutableArray *IDArray = [NSMutableArray array];
    for (int i = 0; i < 18; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [IDNumber substringWithRange:range];
        [IDArray addObject:subString];
    }
    NSArray *coefficientArray = [NSArray arrayWithObjects:@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2", nil];
    NSArray *remainderArray = [NSArray arrayWithObjects:@"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", nil];
    int sum = 0;
    for (int i = 0; i < 17; i++) {
        int coefficient = [coefficientArray[i] intValue];
        int ID = [IDArray[i] intValue];
        sum += coefficient * ID;
    }
    NSString *str = remainderArray[(sum % 11)];
    NSString *string = [IDNumber substringFromIndex:17];
    if ([str isEqualToString:string]) {
        return YES;
    } else {
        return NO;
    }
}
- (CGSize)labelAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading |NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    return labelSize;
}
-(void)addAlertControllerToView:(UIViewController*)view actionArray:(NSArray*)actionArray {
    
    
    UIAlertController*alertController=[UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i=0; i<actionArray.count; i++) {
        UIAlertAction*action=[UIAlertAction actionWithTitle:[actionArray objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"%@",[actionArray objectAtIndex:i]);
            
            NSDictionary*dic=@{@"selectStr":[actionArray objectAtIndex:i]};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"select" object:nil userInfo:dic];
        }];
        [alertController addAction:action];
    }
    [view presentViewController:alertController animated:YES completion:nil];
}
-(void) setImageWithImageView:(UIImageView*)imgView UrlStr:(NSString*)urlStr
{
    
    // 占位图片
    UIImage *placeholder = [UIImage imageNamed:@"jiazaizhong.png"];
    NSURL *url = [NSURL URLWithString:urlStr];
    // 从内存\沙盒缓存中获得原图
    
    
//    NSString* strUrl = @"http://xxx.com/x.jpg";
    NSString* key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    
    
    
    UIImage* cacheImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    //此方法会先从memory中取。
    
    
//    UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    
    
    
    
    
    
    if (cacheImg) { // 如果内存\沙盒缓存有原图，那么就直接显示原图（不管现在是什么网络状态）
        [imgView sd_setImageWithURL:url placeholderImage:placeholder];
    } else { // 内存\沙盒缓存没有原图
        [imgView sd_setImageWithURL:url placeholderImage:placeholder];
    }
}

-(NSString *)StringFromTimestamp:(NSString*)timeStamp{
    NSDate * timeDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp intValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeStr = [dateFormatter stringFromDate:timeDate];
    return timeStr;
}

// 字符串时间—>时间戳
-(NSString *)stringToTimestamp:(NSString*)timeStr;{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:timeStr]; //------------将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return [NSString stringWithFormat:@"%ld",(long)timeSp];
}
//时间戳变为格式时间
-(NSString *)timestampToString:(NSString *)timeStamp{
    
    long long time=[timeStamp longLongValue];
    //    如果服务器返回的是13位字符串，需要除以1000，否则显示不正确(13位其实代表的是毫秒，需要除以1000)
//    long long time=[timeStr longLongValue] / 1000;
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;
}

//时间戳变为格式时间
-(NSString *)timestampToStringDay:(NSString *)timeStamp{
    
    long long time=[timeStamp longLongValue];
    //    如果服务器返回的是13位字符串，需要除以1000，否则显示不正确(13位其实代表的是毫秒，需要除以1000)
    //    long long time=[timeStr longLongValue] / 1000;
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;
}

-(NSString *) md5: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}
//添加缺省页
-(void)addQueshengImageToView:(UIView*)supView imageName:(NSString*)imageName hidden:(BOOL)hidden{
    if (hidden) {
        [imageView removeFromSuperview];
        imageView = nil;
    }else{
        if (imageView == nil) {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, supView.frame.size.width, supView.frame.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageNamed:imageName];
            [supView addSubview:imageView];
        }else{
            [supView addSubview:imageView];
        }
    }
    
}

-(BOOL)checkout:(id)result{
    NSString * status =[NSString stringWithFormat:@"%@",[result objectForKey:@"status"]];
    if ([status intValue]==0) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
