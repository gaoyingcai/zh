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

@interface RegistViewController (){
    dispatch_source_t timer;
}


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
                [self getVerifyCode:self->_getSmsCodeBtn];
            }else{
                [self showTextMessage:@"发送失败"];
            }
        }];
    }
}
//获取验证码
-(void)getVerifyCode:(UIButton *)sender{
    __block NSInteger timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    }
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if (timeout <= 0) {
            dispatch_source_cancel(self->timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_getSmsCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
                self->_getSmsCodeBtn.userInteractionEnabled = YES;
                [self->_getSmsCodeBtn setTitleColor:color_green forState:UIControlStateNormal];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_getSmsCodeBtn setTitle:[NSString stringWithFormat:@"%lds",(long)timeout] forState:UIControlStateNormal];
                [self->_getSmsCodeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                NSLog(@"%ld",(long)timeout);
                self->_getSmsCodeBtn.userInteractionEnabled = NO;
                timeout--;
            });
            
        }
    });
    dispatch_resume(timer);
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

-(void)viewWillDisappear:(BOOL)animated{
    if (timer) {
        dispatch_cancel(timer);
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
