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


@implementation SessionViewController
-(void)viewWillAppear:(BOOL)animated{
    [_addView setHidden:YES];
    [self.view sendSubviewToBack:_addView];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    [self checkoutLogin];
    [self refresh];
}


-(void)checkoutLogin{
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
    if (dic == nil) {
        LoginViewController * login = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"login"];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationController pushViewController:login animated:YES];
        
    }else{
        NSDictionary * dic =[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
        NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
        loginData.account = [dic objectForKey:@"accid"];
        loginData.token = [dic objectForKey:@"token"];
        [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
        [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    }
}
- (void)onLogin:(NIMLoginStep)step{
    NSLog(@"%ld",(long)step);
    if (step == NIMLoginStepLoginOK) {
        [self getUserInfo];
        NSLog(@"登录成功");
    }else if (step == NIMLoginStepLoginFailed || step == NIMLoginStepLoseConnection || step == NIMLoginStepNetChanged){
        
        NSDictionary * dic =[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
        NSString *account = [dic objectForKey:@"accid"];
        NSString *token   = [dic objectForKey:@"token"];
        [[[NIMSDK sharedSDK] loginManager] login:account
                                           token:token
                                      completion:^(NSError *error) {
                                          NSLog(@"%@",error);
                                      }];
        NSLog(@"已经退出登录");
    }
}

-(void)getUserInfo{
    
    [DataService requestWithPostUrl:@"/api/common/getIndexData" params:@{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"]} block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            self->announcementDic = [NSMutableDictionary dictionaryWithDictionary:[[result objectForKey:@"data"]objectForKey:@"notice"]];
            self.gonggaoTitleLabel.text =[self->announcementDic objectForKey:@"title"];
            NSDictionary *userInfo = [[result objectForKey:@"data"]objectForKey:@"userInfo"];
            //            [leftBtn setBackgroundImage:[UIImage imageNamed:@"user_info.png"] forState:UIControlStateNormal];
            //            NSString *urlStr = domain_img([userInfo objectForKey:@"head_url"]);
            //            [self.userImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
            int star_num = [[userInfo objectForKey:@"star"] intValue];
            if (star_num == 0) {
                star_num = 1;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }];
}
- (void)viewDidLoad {
    [self checkoutLogin];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"tianjia@2x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
    
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 25, 25);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"user_info.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:leftBtn]];
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
    webView.webViewStr = [announcementDic objectForKey:@"notice_url"];
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


@end
