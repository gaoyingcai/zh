//
//  RecordsessionViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/12/1.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "RecordsessionViewController.h"
#import "UserInfoViewController.h"
#import "TeamInfoViewController.h"

@implementation RecordsessionViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * keepOutView = [[UIView alloc]initWithFrame:self.view.frame];
    keepOutView.backgroundColor = [UIColor colorWithRed:228/255.0 green:230/255.0 blue:235/255.0 alpha:1.0];
    [self.view addSubview:keepOutView];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [keepOutView removeFromSuperview];
    });
}
-(void)getFriendInfo:(NSString *)phone{
    UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
    userInfo.phone = phone;
    userInfo.rightBtn = YES;
    userInfo.postMessage = YES;
    [self.navigationController pushViewController:userInfo animated:YES];
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
