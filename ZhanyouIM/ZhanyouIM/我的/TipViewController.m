//
//  TipViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "TipViewController.h"
#import "UserCell.h"
#import "DataService.h"

@interface TipViewController (){
    NSMutableArray *dataArray;
    NSInteger totalCount;
}

@end

@implementation TipViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    
    self->dataArray = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary * paramDic = @{@"uid":[[self getUserinfo] objectForKey:@"uid"],@"p":@"1"};
    [DataService requestWithPostUrl:@"/api/self/report" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            self->totalCount = [[[result objectForKey:@"data"] objectForKey:@"count"] integerValue];
            self->dataArray = [[result objectForKey:@"data"] objectForKey:@"list"];
            [self->_tableView reloadData];
        }
    }];

}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.backgroundColor = color_lightGray;
    
    static NSString *reuseIdentifier = @"TIP";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [UserCell tipCell];
    }
    
    cell.tipNameLabel.text = [NSString stringWithFormat:@"举报对象:%@",[[dataArray objectAtIndex:indexPath.row] objectForKey:@"username"]];
    cell.tipDateLabel.text = [self timestampToString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"add_time"]];
    
    
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
