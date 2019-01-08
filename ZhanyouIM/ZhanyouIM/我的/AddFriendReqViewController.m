//
//  AddFriendReqViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2019/1/6.
//  Copyright © 2019 Aiwozhonghua. All rights reserved.
//

#import "AddFriendReqViewController.h"
#import "NIMSDK/NIMSDK.h"
#import "UIImageView+WebCache.h"

@interface AddFriendReqViewController ()

@end

@implementation AddFriendReqViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    
    [self.userImg sd_setImageWithURL:[NSURL URLWithString:domain_img(self.userImgUrl)]];
    self.userName.text = self.userNameStr;
    self.userNum.text = self.userNumStr;
}
-(void)send{
    //添加好友
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    request.userId= self.userNum.text;                            //封装用户ID
    //封装验证方式
    request.operation= NIMUserOperationRequest;
    //封装验证方式
    request.message         = self.requestInfo.text;
    //封装自定义验证消息
    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError * _Nullable error) {
        if (error != nil) {
            [self showTextMessage:[NSString stringWithFormat:@"%@",error]];
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
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
