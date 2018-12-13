//
//  SeekHelpViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "SeekHelpViewController.h"
#import "UserCell.h"
#import "DataService.h"

@interface SeekHelpViewController (){
    NSMutableArray *dataArray;
}

@end

@implementation SeekHelpViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    self->dataArray = [NSMutableArray arrayWithCapacity:0];
    
    
    NSDictionary * paramDic = @{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"]};
    [DataService requestWithPostUrl:@"/api/self/supportMsg" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            self->dataArray = [result objectForKey:@"data"];
            [self->_tableView reloadData];
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.backgroundColor = color_lightGray;
    
    static NSString *reuseIdentifier = @"SEEKHELP";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [UserCell seekHelpCell];
        
    }
    
    cell.seekDateLabel.text = [self timestampToString:[[dataArray objectAtIndex:indexPath.row]objectForKey:@"add_time"]];
    NSString * contentStr = [NSString stringWithFormat:@"求助项目:%@",[[dataArray objectAtIndex:indexPath.row]objectForKey:@"content"]];
    NSString * verifyMsgStr = [NSString stringWithFormat:@"审核结果:%@",[[dataArray objectAtIndex:indexPath.row]objectForKey:@"verify_msg"]];
    cell.seekTextView.text = [NSString stringWithFormat:@"%@\n%@",contentStr,verifyMsgStr];
    
    NSString * str = [NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row]objectForKey:@"status"]];
    if ([str isEqualToString:@"0"]) {
        cell.seekStatusLabel.text = @"正在审核";
        cell.seekStatusLabel.textColor = [UIColor yellowColor];
    }else if ([str isEqualToString:@"1"]){
        cell.seekStatusLabel.text =@"通过";
        cell.seekStatusLabel.textColor = color_green;
    }else if ([str isEqualToString:@"2"]){
        cell.seekStatusLabel.text = @"失败";
        cell.seekStatusLabel.textColor = [UIColor redColor];
    }
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
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
