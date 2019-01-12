//
//  SessionViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/11.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "SessionViewController.h"
#import "NoticeViewController.h"
#import "AddFriendViewController.h"
#import "NewGroupViewController.h"
#import "MYSessionViewController.h"
#import "SessionViewController.h"
#import "LoginViewController.h"
#import "WebViewController.h"
#import "DataService.h"
#import "UserViewController.h"
#import "RegistViewController2.h"
#import "RegistViewController3.h"
#import "PayViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface SessionViewController(){
    UIImageView * imageView; //缺省图片
}

@end

@implementation SessionViewController
-(void)viewWillAppear:(BOOL)animated{
    [_addView setHidden:YES];
    [self.view sendSubviewToBack:_addView];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;

    [self checkoutLogin];
    
}

-(void)checkoutLogin{
    NSDictionary * dic = [self getLocalUserinfo];
    if (dic == nil) {
        LoginViewController * login = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"login"];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationController pushViewController:login animated:YES];
    }else{
        [self manualLoginIM];
        [self getUserInfo];
    }
}
-(BOOL)checkout:(id)result{
    NSString * status =[NSString stringWithFormat:@"%@",[result objectForKey:@"status"]];
    if ([status intValue]==0) {
        return YES;
    }
    return NO;
}
-(void)getUserInfo{
    
    [DataService requestWithPostUrl:@"/api/common/getIndexData" params:@{@"uid":[[self getLocalUserinfo] objectForKey:@"uid"]} block:^(id result) {
        if ([self checkout:result]) {
            NSDictionary *noticeDic = [[result objectForKey:@"data"]objectForKey:@"notice"];
            if ([[NSString stringWithFormat:@"%@",[noticeDic objectForKey:@"status"]] isEqualToString:@"1"]) {
                self.noticeBackView.hidden = NO;
                self->announcementDic = [NSMutableDictionary dictionaryWithDictionary:noticeDic];
                self.tableView.frame = CGRectMake(0, 129, self.view.bounds.size.width, self.view.bounds.size.height-129);
            }else{
                self.noticeBackView.hidden = NO;
                self->announcementDic = [NSMutableDictionary dictionaryWithDictionary:noticeDic];
                self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                self.noticeBackView.hidden = YES;
            }
            
            NSDictionary *userInfoDic=[[result objectForKey:@"data"]objectForKey:@"userInfo"];
            [self setUserInfo:userInfoDic];
            NSString *userImgStr = [userInfoDic objectForKey:@"head_url"];
            [self setLeftBtnWithImgStr:userImgStr];
        }else{
            [self showAlertViewWithDic:result];
        }
    }];
}
-(void)setLeftBtnWithImgStr:(NSString*)userImgStr{
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 36, 36);
    leftBtn.layer.cornerRadius = 18;
    leftBtn.layer.masksToBounds = YES;
//    dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(queue, ^{
//        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:domain_img(userImgStr)]]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [leftBtn setBackgroundImage:[self reSizeImage:img toSize:leftBtn.size] forState:UIControlStateNormal];
//        });
//    });
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:domain_img(userImgStr)]]];
    [leftBtn setBackgroundImage:[self reSizeImage:img toSize:leftBtn.size] forState:UIControlStateNormal];
    
    [leftBtn addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:leftBtn]];
    
}
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}
-(void)showAlertViewWithDic:(NSDictionary *)dic{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[dic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
    
    RegistViewController2 * regist2 = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist2"];
    RegistViewController3 * regist3 = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist3"];
    PayViewController * pay = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"pay"];

    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString * status = [dic objectForKey:@"status"];
        switch ([status intValue]) {
            case -1:
                pay.type = @"3";
                [self.navigationController pushViewController:pay animated:YES];
                break;
            case -2:
                regist2.returnToSession = YES;
                [self.navigationController pushViewController:regist2 animated:YES];
                break;
            case -3:
                regist3.returnToSession = YES;
                [self.navigationController pushViewController:regist3 animated:YES];
                break;
            case -4:
                pay.type = @"3";
                [self.navigationController pushViewController:pay animated:YES];
                break;
            case -5:
                pay.type = @"3";
                [self.navigationController pushViewController:pay animated:YES];
                break;
                
            default:
                break;
        }
        
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAllUserInfo];
        LoginViewController * login = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"login"];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationController pushViewController:login animated:YES];
    }];
    
    [alertController addAction:defaultAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)viewDidLoad {
//    [self checkoutLogin];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setBadge:) name:@"sessionBadge" object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(autoLoginIM) name:@"IMAutoLoginOut" object:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"sessionBadge" object:nil userInfo:nil];

    id<NIMSystemNotificationManager> systemNotificationManager = [[NIMSDK sharedSDK] systemNotificationManager];
    [systemNotificationManager addDelegate:self];
    
    if ([[[self getLocalUserinfo] allKeys]containsObject:@"userImg"]) {
        [self setLeftBtnWithImgStr:[[self getLocalUserinfo] objectForKey:@"userImg"]];
    }
}
- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"sessionBadge" object:nil userInfo:@{@"a":@"1"}];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"homeBadge" object:nil userInfo:@{@"a":@"1"}];
}
-(void)setBadge:(NSNotification*)sender{
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.rightBarButtonItem = nil;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 25, 25);
    if (sender.userInfo) {
        app.showBadge = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"tianjia_badge@2x.png"] forState:UIControlStateNormal];
    }else{
        app.showBadge = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"tianjia@2x.png"] forState:UIControlStateNormal];
    }
    [btn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
    
    
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


-(void)showUserInfo:(UIButton*)btn{
    UserViewController* user = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"user"];
//    userInfo.phone = [[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"phone"];
//    userInfo.loginOut=YES;
    [self.navigationController pushViewController:user animated:YES];
    
}

-(void)addBtnAction:(UIButton*)btn{
    
    if (backView == nil) {
        backView = [[UIView alloc]initWithFrame:self.view.frame];
        backView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:backView];
        [self.view bringSubviewToFront:_addView];
    }
    
    if (_addView.hidden) {
        [_addView setHidden:NO];
        [self.view bringSubviewToFront:_addView];
    }else{
        [_addView setHidden:YES];
        [self.view sendSubviewToBack:_addView];
    }
}

- (IBAction)addButtonsAction:(UIButton *)sender {
    
    if (sender.tag == 1) {
        NSLog(@"通知");
        NoticeViewController * notice = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"notice"];
        [self.navigationController pushViewController:notice animated:YES];
    }else if (sender.tag == 2){
        NSLog(@"添加战友");
        AddFriendViewController * addFriend = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"addFriend"];
        [self.navigationController pushViewController:addFriend animated:YES];
    }else if (sender.tag == 3){
        NSLog(@"新建群聊");
        NewGroupViewController * newGroup = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"newGroup"];
        [self.navigationController pushViewController:newGroup animated:YES];
    }
}

- (void)onSelectedRecent:(NIMRecentSession *)recent
             atIndexPath:(NSIndexPath *)indexPath{
    MYSessionViewController *mySession = [[MYSessionViewController alloc] initWithSession:recent.session];
    mySession.phone = recent.session.sessionId;
    [self.navigationController pushViewController:mySession animated:YES];
    
}
- (IBAction)announcementBtnAction:(id)sender {
    NSLog(@"公告");
    /*
     {
     "notice_url" = "http://aiwozhonghua.kh.juanyunkeji.cn/zt/notice.html";
     status = 1;
     title = "\U6cd5\U7b2c\U4e09\U65b9";
     };
     */
    WebViewController *webView = [[WebViewController alloc]init];
    webView.title = [announcementDic objectForKey:@"title"];
    NSString *userid= [[self getLocalUserinfo] objectForKey:@"uid"];
    webView.webViewStr = [NSString stringWithFormat:@"%@?uid=%@",[announcementDic objectForKey:@"notice_url"],userid];
    //    webView.webViewStr = @"https://www.baidu.com/";
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_addView.hidden) {
        [_addView setHidden:YES];
    }
    [backView removeFromSuperview];
    backView =nil;
}

//-(void)autoLoginIM{
//    NSDictionary * dic =[self getUserIMInfo];
//    NSString *account = [dic objectForKey:@"accid"];
//    NSString *token   = [dic objectForKey:@"token"];
//    NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
//    loginData.account = account;
//    loginData.token = token;
//    [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
//}
//- (void)onAutoLoginFailed:(NSError *)error{
//    [self showLogAlert];
//}

//手动登录云信
-(void)manualLoginIM{
    NSDictionary * dic =[self getUserIMInfo];
    NSString *account = [dic objectForKey:@"accid"];
    NSString *token   = [dic objectForKey:@"token"];
    
    NSArray * clientArray = [[[NIMSDK sharedSDK]loginManager] currentLoginClients];
    for (NIMLoginClient *client in clientArray) {
        [[[NIMSDK sharedSDK]loginManager]kickOtherClient:client completion:nil];
    }
    
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    [[[NIMSDK sharedSDK] loginManager] login:account token:token completion:^(NSError *error) {
        if (error) {
            NSLog(@"手动登录失败:%@",error);
        }
    }];
}
- (void)onLogin:(NIMLoginStep)step{
    NSLog(@"appdelete == %ld",(long)step);
    if (step == NIMLoginStepLoginOK) {
        NSLog(@"登录成功");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if(step == NIMLoginStepLoginFailed || step == NIMLoginStepLoseConnection){
        NSLog(@"云信登录失败  -----%ld", (long)step);
        [self showLogAlert];
    }
}
- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType{
    [self showLogAlert];
}
-(void)showLogAlert{
    
    if ([self isLogin]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的账号在其他设备登录,请重新登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIViewController *currentVC = [self getCurrentVC];
            //        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //        [userDefaults removeObjectForKey:user_defaults_user];
            //        [userDefaults synchronize];
            [self deleteAllUserInfo];
            
            if (currentVC.presentingViewController) {
                [currentVC dismissViewControllerAnimated:NO completion:^{
                    if ([currentVC.presentingViewController isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *navi = (UINavigationController *)currentVC.presentingViewController;
                        [navi popToRootViewControllerAnimated:NO];
                    }
                }];
            } else {
                [currentVC.navigationController popToRootViewControllerAnimated:NO];
            }
            
            UITabBarController *rootTab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            rootTab.selectedIndex = 0;
            
            LoginViewController * login = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"login"];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [self.navigationController pushViewController:login animated:YES];
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
- (UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
    
}




//判断登录状态
-(BOOL)isLogin{
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
    if (dic == nil) {
        return NO;
    }
    return YES;
}
//设置用户信息
-(void)setUserInfo:(NSDictionary*)dic{
    NSMutableDictionary *parmDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    if ([[parmDic allKeys]containsObject:@"id"]) {
        [parmDic setObject:[parmDic objectForKey:@"id"] forKey:@"uid"];
    }
    NSMutableDictionary * userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user]];
    if (userInfoDic ==nil) {
        [[NSUserDefaults standardUserDefaults]setObject:parmDic forKey:user_defaults_user];
    }else{
        [userInfoDic addEntriesFromDictionary:[NSMutableDictionary dictionaryWithDictionary:parmDic]];
        [[NSUserDefaults standardUserDefaults]setObject:userInfoDic forKey:user_defaults_user];
    }
}
//返回用户信息 (uid,head_url,love,star,phone,place,username)
-(NSMutableDictionary*)getLocalUserinfo{
    return [[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
}
//返回用户云信信息  (accid, token)
-(NSDictionary*)getUserIMInfo{
    return [[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user_IM];
}
//清空本地缓存的用户所有信息
-(void)deleteAllUserInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:user_defaults_user];
    [userDefaults removeObjectForKey:user_defaults_user_IM];
    [userDefaults synchronize];
}


@end
