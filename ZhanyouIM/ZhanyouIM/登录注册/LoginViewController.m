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
        if (result) {
            NSString *status = [NSString stringWithFormat:@"%@",[result objectForKey:@"status"]];
            if ([status intValue] == 1) {
                [self showTextMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"message"]]];
                return;
            }
            NSLog(@"%@",result);
            NSDictionary * resultDic =@{@"accid":[[result objectForKey:@"data"] objectForKey:@"accid"],@"token":[[result objectForKey:@"data"] objectForKey:@"token"],@"uid":[[result objectForKey:@"data"] objectForKey:@"uid"],@"phone":self.numberTextField.text};
            
            NSString *account = [[result objectForKey:@"data"] objectForKey:@"accid"];
            NSString *token   = [[result objectForKey:@"data"] objectForKey:@"token"];
            [[[NIMSDK sharedSDK] loginManager] login:account
                                               token:token
                                          completion:^(NSError *error) {
                                              NSLog(@"%@",error);
                                          }];
            [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    
            
            [[NSUserDefaults standardUserDefaults]setObject:resultDic forKey:user_defaults_user];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
    
    
    
}
- (IBAction)registButtonAction:(UIButton *)sender {
    RegistViewController * regist = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist"];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController pushViewController:regist animated:YES];
}


- (void)onLogin:(NIMLoginStep)step{
    NSLog(@"%ld",(long)step);
    if (step == NIMLoginStepLoginOK) {
        NSLog(@"登录成功");
    }else if (step == NIMLoginStepLoginFailed || step == NIMLoginStepLoseConnection || step == NIMLoginStepNetChanged){
        
        NSDictionary * dic =[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
        NSString *account = [dic objectForKey:@"accid"];
        NSString *token   = [dic objectForKey:@"token"];
        [[[NIMSDK sharedSDK] loginManager] login:account
                                           token:token
                                      completion:^(NSError *error) {
                                          NSLog(@"%@",error);
                                      }];
        NSLog(@"已经退出登录");
    }
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
