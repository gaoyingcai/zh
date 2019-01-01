//
//  UserViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/11.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "UserViewController.h"
#import "UserCell.h"
#import "DataService.h"

#import "UserInfoViewController.h"
#import "AidViewController.h"
#import "CircleViewController.h"
#import "SeekHelpViewController.h"
#import "TipViewController.h"
#import "CallCenterViewController.h"
#import "UIImageView+WebCache.h"

@interface UserViewController(){
    NSMutableArray* dataArray;
    NSString *userImgStr;
    NSString *userName;
    int star_num;
}
@end

@implementation UserViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    if (dataArray == nil) {
        dataArray = [NSMutableArray arrayWithObjects:
                     @[@{@"":@""}],
                     @[@{@"name":@"我的资助",@"img":@"资助@2x.png"}],
                     @[@{@"name":@"新闻事实",@"img":@"新闻.png"},
                       @{@"name":@"创业",   @"img":@"创业.png"},
                       @{@"name":@"我的求助",@"img":@"求助.png"},
                       @{@"name":@"我的举报",@"img":@"举报.png"}],
                     @[@{@"name":@"我的客服",@"img":@"客服.png"},
                       @{@"name":@"设置",   @"img":@"设置.png"}], nil];}
    
    
    [DataService requestWithPostUrl:@"/api/user/getUserInfo" params:@{@"phone":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"phone"]} block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            self->userImgStr = domain_img([[result objectForKey:@"data"]objectForKey:@"head_url"]);
            self->userName = [[result objectForKey:@"data"]objectForKey:@"username"];
            [self->_tableView reloadData];
            
            self->star_num = [[[result objectForKey:@"data"] objectForKey:@"star"] intValue];
            if (self->star_num == 0) {
                self->star_num = 1;
            }
        }
    }];
    
    
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.backgroundColor = color_lightGray;
    
    if (indexPath.section == 0) {
        //指定cell的重用标识符
        static NSString *reuseIdentifier = @"USER1";
        //去缓存池找名叫reuseIdentifier的cell
        //这里换成自己定义的cell
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        //如果缓存池中没有,那么创建一个新的cell
        if (!cell) {
            //这里换成自己定义的cell,并调用类方法加载xib文件
            cell = [UserCell userCell1];
        }
        //给cell赋值
        cell.starImgViewContraint.constant = k_star_width * star_num;
        cell.userNameLabel.text = userName;
        [cell.userImg sd_setImageWithURL:[NSURL URLWithString:userImgStr]];
        //返回当前cell
        return cell;
    }
    
    //指定cell的重用标识符
    static NSString *reuseIdentifier = @"USER2";
    //去缓存池找名叫reuseIdentifier的cell
    //这里换成自己定义的cell
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    //如果缓存池中没有,那么创建一个新的cell
    if (!cell) {
        //这里换成自己定义的cell,并调用类方法加载xib文件
        cell = [UserCell userCell2];
    }
    //给cell赋值
    cell.userCellTextLabel.text =[[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.userCellImg.image = [UIImage imageNamed:[[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"img"]];
    //返回当前cell
    return cell;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }else if (section == 2){
        return 4;
    }
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 100;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    if (indexPath.section == 0 || (indexPath.section == 3 && indexPath.row == 1 )) {
        
        UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
        userInfo.phone = [[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"phone"];
        if (indexPath.section == 0){
            userInfo.loginOut =NO;
        }else{
            userInfo.loginOut=YES;
        }
        [self.navigationController pushViewController:userInfo animated:YES];
    }else if (indexPath.section == 1){
        AidViewController* aid = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"aid"];
        [self.navigationController pushViewController:aid animated:YES];
    }else if (indexPath.section == 2 && (indexPath.row == 0 || indexPath.row == 1)){
        CircleViewController*circle=[[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"circle"];
        circle.myDynamic = YES;
        if (indexPath.row == 0) {
            circle.content = @"新闻事实";
        }else if (indexPath.row ==1){
            circle.content = @"创业";
        }
        [self.navigationController pushViewController:circle animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 2){
        SeekHelpViewController* seek = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"seekHelp"];
        [self.navigationController pushViewController:seek animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 3){
        TipViewController* tip = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"tip"];
        [self.navigationController pushViewController:tip animated:YES];
    }else if (indexPath.section == 3 && indexPath.row == 0){
        CallCenterViewController* call = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"callCenter"];
        [self.navigationController pushViewController:call animated:YES];
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


@end
