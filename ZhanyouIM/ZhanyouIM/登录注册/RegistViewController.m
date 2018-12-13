//
//  RegistViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/14.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "RegistViewController.h"
#import "RegistViewController2.h"
#import "DataService.h"

@interface RegistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *smsCode;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation RegistViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


- (IBAction)smsCodeAction:(UIButton *)sender {
    if ([self isValidateMobile:self.phoneTextField.text]) {
        NSDictionary * dic = @{@"phone":self.phoneTextField.text,@"templatecode":@"SMS_126620263"};
        [DataService requestWithPostUrl:@"/api/login/getSmsCode" params:dic block:^(id result) {
            if (result) {
                [self showTextMessage:@"发送成功"];
            }else{
                [self showTextMessage:@"发送失败"];
            }
        }];
    }
}



- (IBAction)registBtnAction:(UIButton *)sender {
    
//    if ([self isValidateMobile:self.phoneTextField.text] && self.smsCode.text.length>0 && self.passwordTextField.text.length>=8) {
//        NSDictionary * paramDic = @{@"phone":self.phoneTextField.text,@"password":self.passwordTextField.text,@"vercode":self.smsCode.text};
////        NSDictionary * paramDic = @{@"phone":@"18132442523",@"password":@"1234567890",@"vercode":@"4255"};
//        [DataService requestWithPostUrl:@"/api/login/regist" params:paramDic block:^(id result) {
//            if (result) {
                RegistViewController2 * regist2 = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist2"];
                    regist2.phone = self.phoneTextField.text;
    regist2.source = @"注册";
                [self.navigationController pushViewController:regist2 animated:YES];
//            }else{
//                [self showTextMessage:@"注册失败"];
//            }
//        }];
//    }
    
    
    
    
    
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_passwordTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
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
