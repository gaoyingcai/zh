//
//  LoginViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/14.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistViewController.h"
#import "HomeViewController.h"
#import "ForgetPasswordViewController.h"
#import "DataService.h"
#import <NIMSDK/NIMSDK.h>

@interface LoginViewController ()<NIMLoginManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)forgetAction:(UIButton *)sender {
    ForgetPasswordViewController * forget = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"forget"];
    [self.navigationController pushViewController:forget animated:YES];
}

- (IBAction)loginBtnAction:(id)sender {
    NSDictionary *paramDic = @{@"phone":self.numberTextField.text,@"pwd":[self md5:self.passwordTextField.text]};
    if (self.numberTextField.text.length!=11) {
        [self showTextMessage:@"请输入正确手机号"];
    }else if (self.passwordTextField.text.length <6){
        [self showTextMessage:@"请输入密码"];
    }
    [DataService requestWithPostUrl:@"api/login/login" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            
            [self setUserInfo:@{@"uid":[[result objectForKey:@"data"] objectForKey:@"uid"],@"phone":[[result objectForKey:@"data"] objectForKey:@"accid"]}];
            [self setUserIMInfo: @{@"accid":[[result objectForKey:@"data"] objectForKey:@"accid"],@"token":[[result objectForKey:@"data"] objectForKey:@"token"]}];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self showTextMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"message"]]];
            return;
        }
    }];
}
- (IBAction)registButtonAction:(UIButton *)sender {
    RegistViewController * regist = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist"];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController pushViewController:regist animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_passwordTextField resignFirstResponder];
    [_numberTextField resignFirstResponder];
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
