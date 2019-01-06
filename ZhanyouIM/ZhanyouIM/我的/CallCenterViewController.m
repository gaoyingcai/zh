//
//  CallCenterViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "CallCenterViewController.h"
#import "DataService.h"

@interface CallCenterViewController ()

@end

@implementation CallCenterViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.callLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [DataService requestWithGetUrl:@"/api/config/getService" params:nil block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            self.phoneLabel.text = [[result objectForKey:@"data"] objectForKey:@"phone"];
//            self.phoneLabel.text = @"17326822629";
            self.wechatNumLabel.text = [[result objectForKey:@"data"] objectForKey:@"wx_number"];
        }
    }];
}
- (IBAction)callBtnAction:(id)sender {
    NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", self.phoneLabel.text];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.phoneLabel.text]];
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
