//
//  AidViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "AidViewController.h"
#import "UserCell.h"
#import "DataService.h"

@interface AidViewController (){
    NSMutableArray * dataArray;
    NSInteger totalCount;
}

@end

@implementation AidViewController

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
    [DataService requestWithPostUrl:@"/api/self/support" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
//            self->totalCount = [[[result objectForKey:@"data"] objectForKey:@"count"] integerValue];
            self->dataArray = [result objectForKey:@"data"];
            self->totalCount = self->dataArray.count;
                               
            [self->_tableView reloadData];
        }
    }];
    
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.backgroundColor = color_lightGray;
    
    static NSString *reuseIdentifier = @"AID";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [UserCell aidCell];
    }
    
    cell.aidNameLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"username"];
    cell.aidSumLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"money"];
    cell.aidDateLabel.text = [self timestampToString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"add_time"]];

    return cell;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
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
