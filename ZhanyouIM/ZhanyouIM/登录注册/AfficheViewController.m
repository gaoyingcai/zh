//
//  AfficheViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/15.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "AfficheViewController.h"
#import "PayViewController.h"

@interface AfficheViewController ()

@end

@implementation AfficheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)noAgreeAtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)agreeBtnAction:(id)sender {
    PayViewController * pay = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"pay"];
    pay.type = @"1";
    [self.navigationController pushViewController:pay animated:YES];
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
