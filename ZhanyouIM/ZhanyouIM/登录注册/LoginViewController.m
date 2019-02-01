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
#import "UILabel+YBAttributeTextTapAction.h"
#import "WebViewController.h"

@interface LoginViewController ()<NIMLoginManagerDelegate,YBAttributeTapActionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UILabel *agreementLabel;

@end

@implementation LoginViewController
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    if ([[[NIMSDK sharedSDK] loginManager] isLogined]) {
        [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
            NSLog(@"%@",error);
            if (error == nil) {
                [self deleteAllUserInfo];
            }
        }];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setAgreementStr];
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
            [self.navigationController popToRootViewControllerAnimated:NO];
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




- (void)setAgreementStr
{
    NSString *agreementStr = @"点击登录或注册代表您同意《用户协议》和《隐私政策》";
    NSMutableArray *ranges = [NSMutableArray array]; // 特殊字符的Range集合,修改文字颜用
    NSMutableArray *actionStrs = [NSMutableArray array];
    [actionStrs addObject:@"《用户协议》"];
    [actionStrs addObject:@"《隐私政策》"];
    NSRange range1 = [agreementStr rangeOfString:@"《用户协议》"];
    NSRange range2 = [agreementStr rangeOfString:@"《隐私政策》"];
    [ranges addObject:[NSValue valueWithRange:range1]];
    [ranges addObject:[NSValue valueWithRange:range2]];
    
    // 转换成富文本字符串
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:agreementStr];
    [attrStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f]} range:NSMakeRange(0, agreementStr.length)];
    // 最好设置一下行高，不设的话默认是0
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 0;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, agreementStr.length)];
    // 给指定文字添加颜色
    for (NSValue *rangeVal in ranges) {
        [attrStr addAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor]} range:rangeVal.rangeValue];
    }
    
    self.agreementLabel.attributedText = attrStr;
    self.agreementLabel.textAlignment = NSTextAlignmentCenter;
    // 给指定文字添加点击事件,并设置代理,代理中监听点击
    [self.agreementLabel yb_addAttributeTapActionWithStrings:actionStrs delegate:self];

}
-(void)yb_tapAttributeInLabel:(UILabel *)label string:(NSString *)string range:(NSRange)range index:(NSInteger)index{
    NSLog(@"点击了协议");
    
    WebViewController *webView = [[WebViewController alloc]init];
    webView.title = string;
    webView.webViewStr = @"http://aiwozhonghua-test2.kh.juanyunkeji.cn/zt/notice_tell.html";
    [self.navigationController pushViewController:webView animated:YES];
}


@end
