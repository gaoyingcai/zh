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

@interface AddFriendViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *searchMeArr;
    NSMutableArray *mySearchArr;
    UITableView * searchMeTableView;
    UITableView * mySearchTableView;

}

@end

@implementation AddFriendViewController
-(void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.searchBar.subviews[0].backgroundColor = [UIColor whiteColor];
//    [_searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
    
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
    
    RegistViewController2 * regist2 = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist2"];
    regist2.source = @"查找";
    
    regist2.passValueBlock= ^(NSArray* array){
        self->mySearchArr = [NSMutableArray arrayWithArray:array];
        [self mySearchAction:nil];
    };
    [self.navigationController pushViewController:regist2 animated:YES];
}

- (IBAction)searcMeAction:(id)sender {
    [self.searchMeBtn setTitleColor:color_green forState:UIControlStateNormal];
    self.searchMeLine.backgroundColor = color_green;
    [self.mySearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.mySearchLine.backgroundColor = [UIColor clearColor];
    self.scrollView.contentOffset=CGPointMake(0, 0);
    
    
    NSDictionary * paramDic = [NSDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user]];

    [DataService requestWithPostUrl:@"api/user/findMe" params:@{@"uid":[paramDic objectForKey:@"uid"]} block:^(id result) {
        if (result) {
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
- (IBAction)mySearchAction:(id)sender {
    [self searchBtnAction:nil];
//    [self.searchMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.searchMeLine.backgroundColor = [UIColor clearColor];
//    [self.mySearchBtn setTitleColor:color_green forState:UIControlStateNormal];
//    self.mySearchLine.backgroundColor = color_green;
//    self.scrollView.contentOffset=CGPointMake(k_screen_width, 0);
//    if (!mySearchArr.count) {
//        [self addQueshengImageToView:mySearchTableView imageName:@"sousuo@2x.png" hidden:NO];
//    }else{
//        [self addQueshengImageToView:mySearchTableView imageName:@"sousuo@2x.png" hidden:YES];
//    }
//    [mySearchTableView reloadData];
    
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
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    NSLog(@"%@",mySearchArr);
    request.userId          = [[mySearchArr objectAtIndex:btn.tag] objectForKey:@"phone"];                            //封装用户ID
    request.operation       = NIMUserOperationRequest;                    //封装验证方式
//    request.operation       = NIMUserOperationAdd;                    //封装验证方式
    request.message         = @"请求添加好友";                                 //封装自定义验证消息
    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError * _Nullable error) {
        if (error != nil) {
            [self showTextMessage:[NSString stringWithFormat:@"%@",error]];
        }
    }];

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
