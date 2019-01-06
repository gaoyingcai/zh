//
//  UserInfoViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserCell.h"
#import "DataService.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "NIMSDK/NIMSDK.h"
#import "ReportViewController.h"
#import "MYSessionViewController.h"
#import "AddFriendReqViewController.h"

@interface UserInfoViewController (){
    NSMutableArray* dataArray;
    NSMutableArray *myFriendArr;
    NSString *userImgStr;
    NSString *userNameStr;
}

//"exit_time" = 1540224000;
//"head_url" = "/Public/upload/photo/2018-10-23/5bcebd07501d4.png";
//id = 4;
//"join_time" = 1540224000;
//love = 0;
//phone = 17692134898;
//place = "\U6cb3\U5317\U7701\U77f3\U5bb6\U5e84\U5e02\U957f\U5b89\U533a";
//star = 0;
//status = 0;
//"team_num" = 250;
//username = lx001;



@end

@implementation UserInfoViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    myFriendArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyFriend"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    if (_rightBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setBackgroundImage:[UIImage imageNamed:@"更多@2x.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
    }

    [DataService requestWithPostUrl:@"/api/user/getUserInfo" params:@{@"phone":_phone} block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
//            self->userImgStr = domain_img([[result objectForKey:@"data"]objectForKey:@"head_url"]);
//            self->userName = [[result objectForKey:@"data"]objectForKey:@"username"];
            self->userImgStr =[[result objectForKey:@"data"]objectForKey:@"head_url"];
            self->userNameStr =[[result objectForKey:@"data"]objectForKey:@"username"];
            if (self->dataArray == nil) {
                self->dataArray = [NSMutableArray arrayWithObjects:
                                   @[@{@"text":@"头像",@"info":domain_img(self->userImgStr)}],
                                   @[@{@"text":@"姓名",@"info":self->userNameStr},
                               @{@"text":@"籍贯",@"info":[[result objectForKey:@"data"]objectForKey:@"place"]},
                               @{@"text":@"手机号",@"info":[[result objectForKey:@"data"]objectForKey:@"phone"]}],
                             @[@{@"text":@"番号",@"info":[[result objectForKey:@"data"]objectForKey:@"team_num"]},
                               @{@"text":@"入伍年月",@"info":[[result objectForKey:@"data"]objectForKey:@"join_time"]},
                               @{@"text":@"退伍年月",@"info":[[result objectForKey:@"data"]objectForKey:@"exit_time"]}], nil];
                [self->_tableView reloadData];
            }
        }
    }];
}
-(void)moreInfo{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet] ;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"举报战友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ReportViewController * report = [[UIStoryboard storyboardWithName:@"Session" bundle:nil] instantiateViewControllerWithIdentifier:@"report"];
        report.reportId = self->_phone;
        [self.navigationController pushViewController:report animated:YES];
    }]] ;
    [alert addAction:[UIAlertAction actionWithTitle:@"删除战友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NIMSDK sharedSDK].userManager deleteFriend:self->_phone completion:^(NSError * _Nullable error) {
            if (error) {
                [self showTextMessage:@"删除失败"];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }]] ;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.backgroundColor = color_lightGray;
    
    if (indexPath.section == 0) {
        static NSString *reuseIdentifier = @"USERINFO1";
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [UserCell userInfoCell1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.userImg sd_setImageWithURL:[NSURL URLWithString:[[[dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"info"]]];
        return cell;
    }else if (indexPath.section == 1 ||indexPath.section ==2){
        static NSString *reuseIdentifier = @"USERINFO2";
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [UserCell userInfoCell2];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userinfoTextLabel.text =[[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"text"];
        if ([[[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"info"] isKindOfClass:[NSNull class]]) {
            cell.userInfoLabel.text = @"空";
        }else if(indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 2)){
            cell.userInfoLabel.text = [self timestampToStringDay:[[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"info"]];
        }else{
            cell.userInfoLabel.text =[[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"info"];
        }
        
        return cell;
    }
    
    if (_loginOut) {
        static NSString *reuseIdentifier = @"LOGOUT";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = color_lightGray;
        
        UILabel * logoutLabel  = [[UILabel alloc]initWithFrame:CGRectMake(15, 1, k_screen_width - 30, 50)];
        logoutLabel.backgroundColor = [UIColor redColor];
        logoutLabel.textColor = [UIColor whiteColor];
        logoutLabel.text = @"退出登录";
        logoutLabel.layer.cornerRadius = 3;
        logoutLabel.layer.masksToBounds= YES;
        logoutLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:logoutLabel];
        
        return cell;
    }
    
    //发消息
    static NSString *reuseIdentifier = @"LOGOUT";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = color_lightGray;
    
    UILabel * logoutLabel  = [[UILabel alloc]initWithFrame:CGRectMake(15, 1, k_screen_width - 30, 38)];
    logoutLabel.backgroundColor = color_green;
    logoutLabel.textColor = [UIColor whiteColor];
    
    if ([myFriendArr containsObject:_phone]) {
        logoutLabel.text = @"发送消息";
    }else{
        logoutLabel.text = @"添加好友";
    }
    logoutLabel.layer.cornerRadius = 3;
    logoutLabel.layer.masksToBounds= YES;
    logoutLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:logoutLabel];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_loginOut||_postMessage) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 3) {
        return 1;
    }
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 100;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
//    if (indexPath.section == 0 || (indexPath.section == 3 && indexPath.row == 1 )) {
//        UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
//        [self.navigationController pushViewController:userInfo animated:YES];
//    }
    
    
    if (indexPath.section == 3) {
        
        if (_loginOut) {
            
            
            [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {

                NSLog(@"%@",error);
            }];
            
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //        NSDictionary *dic = [userDefaults dictionaryRepresentation];
            [userDefaults removeObjectForKey:user_defaults_user];
            [userDefaults synchronize];
            LoginViewController * login = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"login"];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [self.navigationController pushViewController:login animated:YES];
        }else if (_postMessage){
            if ([myFriendArr containsObject:_phone]) {
                
                NIMSession *session = [NIMSession session:_phone type:NIMSessionTypeP2P];
                MYSessionViewController *sessionVc = [[MYSessionViewController alloc] initWithSession:session];
                sessionVc.phone =_phone;
                self.tabBarController.tabBar.hidden = YES;
                [self.navigationController pushViewController:sessionVc animated:YES];
            }else{
                AddFriendReqViewController * add = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"addFri"];
                add.userImgUrl = userImgStr;
                add.userNameStr = userNameStr;
                add.userNumStr = _phone;
                [self.navigationController pushViewController:add animated:YES];
            }
            
        }
        
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
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
