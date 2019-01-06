//
//  MYSessionViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/10.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "MYSessionViewController.h"
#import "UserInfoViewController.h"
#import "TeamInfoViewController.h"


@interface MYSessionViewController ()<NIMMessageCellDelegate>

@end

@implementation MYSessionViewController
-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    self.tabBarController.tabBar.hidden = YES;
    if (self.navigationController.viewControllers.count>1) {
        UIViewController *homeController = self.navigationController.viewControllers.firstObject;
        self.navigationController.viewControllers = @[homeController,self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 25, 25);
    if (self.session.sessionType == NIMSessionTypeP2P) {
        [btn setBackgroundImage:[UIImage imageNamed:@"user_info@2x.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(getFriendInfo) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"team_info@2x.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(getTeamInfo) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
    
    
    UIView * keepOutView = [[UIView alloc]initWithFrame:self.view.frame];
    keepOutView.backgroundColor = [UIColor colorWithRed:228/255.0 green:230/255.0 blue:235/255.0 alpha:1.0];
    [self.view addSubview:keepOutView];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [keepOutView removeFromSuperview];
    });

    
    
}
-(void)getFriendInfo{
    [self getFriendInfo:_phone];
}
-(void)getFriendInfo:(NSString *)phone{
    UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
    userInfo.phone = phone;
    userInfo.rightBtn = YES;
    userInfo.postMessage = YES;
    [self.navigationController pushViewController:userInfo animated:YES];
}
-(void)getTeamInfo{
    TeamInfoViewController * teaminfo = [[UIStoryboard storyboardWithName:@"Session" bundle:nil] instantiateViewControllerWithIdentifier:@"teamInfo"];
    teaminfo.teamId = self.session.sessionId;
    [self.navigationController pushViewController:teaminfo animated:YES];
}

- (BOOL)onTapAvatar:(NSString *)userId{
    //记得添加 NIMMessageCellDelegate 代理，并重写该方法
    NSLog(@"点击头像");
    [self getFriendInfo:userId];
    return YES;
}

- (BOOL)onLongPressCell:(NIMMessage *)message
                 inView:(UIView *)view {
    //同上，重写该方法进行自定义操作
    NSLog(@"长按头像");
    return YES;
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
