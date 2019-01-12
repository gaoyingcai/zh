//
//  ForgetPasswordViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/17.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "DataService.h"

@interface ForgetPasswordViewController (){
    dispatch_source_t timer;
}

@end

@implementation ForgetPasswordViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _getSmsCodeBtn.layer.cornerRadius = 5.0;//2.0是圆角的弧度，根据需求自己更改
    _getSmsCodeBtn.layer.borderColor = color_lightGray.CGColor;//设置边框颜色
    _getSmsCodeBtn.layer.borderWidth = 2.0f;//设置边框宽度
}

- (IBAction)getSmsCodeAction:(UIButton *)sender {
    
    if ([self isValidateMobile:self.mobileNumTextField.text]) {
        NSDictionary * dic = @{@"phone":self.mobileNumTextField.text,@"templatecode":@"SMS_126620262"};
        [DataService requestWithPostUrl:@"/api/login/getSmsCode" params:dic block:^(id result) {
            if ([self checkout:result]) {
                [self showTextMessage:@"发送成功"];
                [self getVerifyCode:self->_getSmsCodeBtn];
            }else{
                [self showTextMessage:[result objectForKey:@"message"]];
                
            }
        }];
    }else{
        [self showTextMessage:@"请输入正确手机号"];
    }
}
//获取验证码
-(void)getVerifyCode:(UIButton *)sender{
    __block NSInteger timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    }else{
        dispatch_cancel(timer);
        timer = nil;
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    }
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if (timeout <= 0) {
            dispatch_source_cancel(self->timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_getSmsCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
                self->_getSmsCodeBtn.userInteractionEnabled = YES;
//                [self->_getSmsCodeBtn setTitleColor:color_green forState:UIControlStateNormal];
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
- (IBAction)finishBtnAction:(id)sender {
    if ([self isValidateMobile:self.mobileNumTextField.text] && self.smsCodeTextField.text.length == 4 &&self.passWordTextField.text.length) {
        NSDictionary * dic = @{@"phone":self.mobileNumTextField.text,@"vcode":self.smsCodeTextField.text,@"new_pwd":[self md5:self.passWordTextField.text]};
        [DataService requestWithPostUrl:@"/api/login/setpwdbyphone" params:dic block:^(id result) {
            if ([self checkout:result]) {
                [self showTextMessage:@"修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self showTextMessage:[result objectForKey:@"message"]];
            }
        }];
    }else{
        [self showTextMessage:@"请输入正确信息"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.smsCodeTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    [self.mobileNumTextField resignFirstResponder];
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
