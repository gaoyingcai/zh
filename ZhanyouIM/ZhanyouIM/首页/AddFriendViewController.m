//
//  AddFriendViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "AddFriendViewController.h"
#import "HomeCell.h"
#import "DataService.h"
#import "RegistViewController2.h"
#import "UIImageView+WebCache.h"
#import <NIMSDK/NIMSDK.h>
#import "UserInfoViewController.h"

@interface AddFriendViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *searchMeArr;
    NSMutableArray *mySearchArr;
    UITableView * searchMeTableView;
    UITableView * mySearchTableView;
    BOOL showMysearch;
}

@end

@implementation AddFriendViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    
//    if (self.scrollView.contentOffset.x<k_screen_width) {
//        [self searcMeAction:nil];
//    }
    if (showMysearch) {
        [self setMySearchBtnStatus];
        showMysearch = NO;
    }else{
        [self searcMeAction:nil];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.searchBar.subviews[0].backgroundColor = [UIColor whiteColor];
//    [_searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
    showMysearch = NO;
    UIView *firstSubView = self.searchBar.subviews.firstObject;
    firstSubView.backgroundColor = [UIColor clearColor];
    UIView *backgroundImageView = [firstSubView.subviews firstObject];
//    backgroundImageView.backgroundColor= [UIColor clearColor];
    [backgroundImageView removeFromSuperview];
    
    
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.contentSize=CGSizeMake(k_screen_width*2, k_view_height(self.scrollView));
    
    for (int i=0; i<2; i++) {
        UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(k_screen_width*i, 0, k_screen_width, k_view_height(self.scrollView)) style:UITableViewStylePlain];
        tableView.tag = i;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = color_lightGray;
        [self.scrollView addSubview:tableView];
        
        if (i == 0) {
            searchMeTableView = tableView;
            searchMeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }else{
            mySearchTableView = tableView;
            mySearchTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    
    [self searcMeAction:nil];
}

- (IBAction)searchBtnAction:(id)sender {
    
    showMysearch =YES;
    RegistViewController2 * regist2 = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist2"];
    regist2.source = @"查找";
    
    regist2.passValueBlock= ^(NSArray* array){
        self->mySearchArr = [NSMutableArray arrayWithArray:array];
        [self setMySearchBtnStatus];
    };
    [self.navigationController pushViewController:regist2 animated:YES];
}

- (IBAction)searcMeAction:(id)sender {
    [self.searchMeBtn setTitleColor:color_green forState:UIControlStateNormal];
    self.searchMeLine.backgroundColor = color_green;
    [self.mySearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.mySearchLine.backgroundColor = [UIColor clearColor];
    self.scrollView.contentOffset=CGPointMake(0, 0);
    
    [DataService requestWithPostUrl:@"api/user/findMe" params:@{@"uid":[[self getUserinfo] objectForKey:@"uid"]} block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@", result);
            self->searchMeArr = [NSMutableArray arrayWithArray:[[result objectForKey:@"data"]objectForKey:@"list"]];
            
            if (!self->searchMeArr.count) {
                [self addQueshengImageToView:self->searchMeTableView imageName:@"zhanyou@2x.png" hidden:NO];
            }else{
                [self addQueshengImageToView:self->searchMeTableView imageName:@"zhanyou@2x.png" hidden:YES];
            }
            [self->searchMeTableView reloadData];

        }

    }];
    
}
-(void)setMySearchBtnStatus{
    [self.searchMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.searchMeLine.backgroundColor = [UIColor clearColor];
    [self.mySearchBtn setTitleColor:color_green forState:UIControlStateNormal];
    self.mySearchLine.backgroundColor = color_green;
    self.scrollView.contentOffset=CGPointMake(k_screen_width, 0);
    if (!mySearchArr.count) {
        [self addQueshengImageToView:mySearchTableView imageName:@"sousuo@2x.png" hidden:NO];
    }else{
        [self addQueshengImageToView:mySearchTableView imageName:@"sousuo@2x.png" hidden:YES];
    }
    [mySearchTableView reloadData];

}
- (IBAction)mySearchAction:(id)sender {
    [self setMySearchBtnStatus];
    [self searchBtnAction:nil];
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isKindOfClass:[UITableView class]]) {
        if (scrollView.contentOffset.x < k_screen_width/2) {
            [self searcMeAction:nil];
        }else{
            [self mySearchAction:nil];
        }
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //指定cell的重用标识符
    static NSString *reuseIdentifier = @"HOMEADD";
    //去缓存池找名叫reuseIdentifier的cell
    //这里换成自己定义的cell
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    //如果缓存池中没有,那么创建一个新的cell
    if (!cell) {
        //这里换成自己定义的cell,并调用类方法加载xib文件
        cell = [HomeCell homeAddCell];
    }
    //给cell赋值
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView.tag == 0) {
        cell.nameLabel.text =[[searchMeArr objectAtIndex:indexPath.row] objectForKey:@"username"];
        cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imgView.layer.masksToBounds =YES;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:domain_img([[searchMeArr objectAtIndex:indexPath.row] objectForKey:@"head_url"])]];
    }else{
        cell.phoneLabel.text = [[mySearchArr objectAtIndex:indexPath.row] objectForKey:@"phone"];
        cell.nameLabel.text =[[mySearchArr objectAtIndex:indexPath.row] objectForKey:@"username"];
        cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imgView.layer.masksToBounds =YES;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:domain_img([[mySearchArr objectAtIndex:indexPath.row] objectForKey:@"head_url"])]];
    }
    cell.addBtn.tag = indexPath.row;
    [cell.addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //返回当前cell
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.tag == 0) {
        return searchMeArr.count;
    }
    
    return mySearchArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)addBtnAction:(UIButton*)btn{
    
    NSLog(@"%@",mySearchArr);
    if (mySearchArr.count) {
        if ([[[self getUserinfo] objectForKey:@"phone"] isEqualToString:[[mySearchArr objectAtIndex:btn.tag] objectForKey:@"phone"]]) {
            [self showTextMessage:@"您不能添加自己为好友"];
            return;
        }
        showMysearch =YES;
        UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
        userInfo.phone = [[mySearchArr objectAtIndex:btn.tag] objectForKey:@"phone"];
        userInfo.rightBtn = NO;
        userInfo.postMessage = YES;
        [mySearchArr removeObjectAtIndex:btn.tag];
        [mySearchTableView reloadData];
        [self.navigationController pushViewController:userInfo animated:YES];
    }else if(searchMeArr.count){
        if ([[[self getUserinfo] objectForKey:@"phone"] isEqualToString:[[searchMeArr objectAtIndex:btn.tag] objectForKey:@"phone"]]) {
            [self showTextMessage:@"您不能添加自己为好友"];
            return;
        }
        UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
        userInfo.phone = [[searchMeArr objectAtIndex:btn.tag] objectForKey:@"phone"];
        userInfo.rightBtn = NO;
        userInfo.postMessage = YES;
        [searchMeArr removeObjectAtIndex:btn.tag];
        [searchMeTableView reloadData];
        [self.navigationController pushViewController:userInfo animated:YES];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%@",mySearchArr);
    if (mySearchArr.count) {
        if ([[[self getUserinfo] objectForKey:@"phone"] isEqualToString:[[mySearchArr objectAtIndex:indexPath.row] objectForKey:@"phone"]]) {
            [self showTextMessage:@"您不能添加自己为好友"];
            return;
        }
        showMysearch = YES;
        UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
        userInfo.phone = [[mySearchArr objectAtIndex:indexPath.row] objectForKey:@"phone"];
        userInfo.rightBtn = NO;
        userInfo.postMessage = YES;
        [mySearchArr removeObjectAtIndex:indexPath.row];
        [mySearchTableView reloadData];
        [self.navigationController pushViewController:userInfo animated:YES];
    }else if(searchMeArr.count){
        if ([[[self getUserinfo] objectForKey:@"phone"] isEqualToString:[[searchMeArr objectAtIndex:indexPath.row] objectForKey:@"phone"]]) {
            [self showTextMessage:@"您不能添加自己为好友"];
            return;
        }
        showMysearch = YES;
        UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
        userInfo.phone = [[searchMeArr objectAtIndex:indexPath.row] objectForKey:@"phone"];
        userInfo.rightBtn = NO;
        userInfo.postMessage = YES;
        [self.navigationController pushViewController:userInfo animated:YES];
    }
}

//-(void)accessBtnAction:(UIButton*)btn{
//    NIMUserRequest *request = [[NIMUserRequest alloc] init];
//    request.userId          = [[mySearchArr objectAtIndex:btn.tag] objectForKey:@"id"];                            //封装用户ID
//    request.operation       = NIMUserOperationVerify;                    //封装验证方式
//    request.message         = @"";                                 //封装自定义验证消息
//    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError * _Nullable error) {
//        NSLog(@"%@",error);
//    }];
//
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
