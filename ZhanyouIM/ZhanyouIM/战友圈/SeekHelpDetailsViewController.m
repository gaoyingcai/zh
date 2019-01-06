//
//  SeekHelpDetailsViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "SeekHelpDetailsViewController.h"
#import "DataService.h"
#import <UIImageView+WebCache.h>
#import "WXApi.h"

@interface SeekHelpDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat width;
    CGFloat height;
    NSMutableArray * tableViewDataArray;
    NSString * suid;
}

@end

@implementation SeekHelpDetailsViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    [self loadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.billTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.billTableView.backgroundColor = [UIColor redColor];
//    self.billTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)initViewWith:(NSMutableDictionary*)dataDic{
    tableViewDataArray = [NSMutableArray arrayWithArray:[dataDic objectForKey:@"comments"]];
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:domain_img([dataDic objectForKey:@"head_url"])]];
    self.userName.text= [dataDic objectForKey:@"username"];
    self.content.numberOfLines = 0;
    self.content.text = [dataDic objectForKey:@"content"];
    suid = [dataDic objectForKey:@"uid"];
    
    CGFloat top = self.content.frame.origin.y + self.content.frame.size.height;
    
    CGFloat width = k_screen_width/3-28;
    CGFloat height = k_screen_width/3-28;
    
    NSMutableArray * imgArray = [dataDic objectForKey:@"path"];
    NSInteger num = imgArray.count;
    if (num == 1) {
        CGSize singleSize = [Utility getSingleSize:CGSizeMake(500, 315)];
        width = singleSize.width;
        height = singleSize.height;
    }else{
        width = k_screen_width/3-28;
        height = k_screen_width/3-28;
    }
    for (int i = 0; i<num; i++) {
        UIImageView *imgView=[[UIImageView alloc]init];
        imgView.frame=CGRectMake(i*width +10, i*width +10+top, width, height);
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
        [imgView sd_setImageWithURL:[NSURL URLWithString:domain_img([[imgArray objectAtIndex:i] objectForKey:@"path_source_img"])]];
        [self.backView addSubview:imgView];
    }
    
    
    if (num%3) {
        top += (num/3+1)*(height+10)+10;
    }else{
        top += num/3*(height+10)+10;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backViewConstraintHeight.constant = top+40;//需要加上爱心流水按钮的高度
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [self.billTableView reloadData];
    }];
}
-(void)loadData{
    
    NSDictionary * paramDic = @{@"id":[NSString stringWithFormat:@"%d",_commentId]};
    [DataService requestWithPostUrl:@"api/list/getItem" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self initViewWith:[[result objectForKey:@"data"] objectAtIndex:0]];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu",(unsigned long)tableViewDataArray.count);
    return tableViewDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MomentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.contentView removeFromSuperview];
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width/2, 30)];
    nameLabel.text =[[tableViewDataArray objectAtIndex:indexPath.row]objectForKey:@"username"];
    nameLabel.textColor = [UIColor darkGrayColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [cell addSubview:nameLabel];
    
    UILabel * moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width/2, 0, tableView.frame.size.width/2, 30)];
    moneyLabel.textAlignment= NSTextAlignmentRight;
    moneyLabel.text =[NSString stringWithFormat:@"捐出%@元",[[tableViewDataArray objectAtIndex:indexPath.row]objectForKey:@"money"]];
    moneyLabel.textColor = [UIColor darkGrayColor];
    moneyLabel.font = [UIFont systemFontOfSize:15];
    [cell addSubview:moneyLabel];
    
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
- (IBAction)helpBtnAction:(id)sender {
    NSDictionary * paramDic = @{@"field":@"sup_money"};
    [DataService requestWithPostUrl:@"api/config/getConfig" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self alert:[[result objectForKey:@"data"] objectForKey:@"money"]];
        }
    }];
}
-(void)alert:(NSString*)money{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否捐助一颗爱心给他" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pay:money];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)pay:(NSString*)payMoney{
    
    NSDictionary *paramDic = @{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"],
                          @"money":payMoney,
                          @"suid":suid,
                          @"info_id":[NSString stringWithFormat:@"%d",_commentId],
                          @"type":@"2",
                          };
    
    [DataService requestWithPostUrl:@"/api/payment/payOrder" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self setOrderString:[result objectForKey:@"data"]];
        }
    }];
}
-(void)setOrderString:(NSDictionary*)dic{
    
    if ([dic objectForKey:@"partnerid"]) {
        PayReq *request = [[PayReq alloc] init];
        request.partnerId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"partnerid"]];
        request.prepayId= [NSString stringWithFormat:@"%@",[dic objectForKey:@"prepayid"]];
        request.package = @"Sign=WXPay";
        request.nonceStr= [NSString stringWithFormat:@"%@",[dic objectForKey:@"noncestr"]];
        request.timeStamp= [[dic objectForKey:@"timestamp"] intValue];
        request.sign= [NSString stringWithFormat:@"%@",[dic objectForKey:@"sign"]];
        [WXApi sendReq:request];
    }
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
