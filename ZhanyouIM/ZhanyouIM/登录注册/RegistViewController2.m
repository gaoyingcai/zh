//
//  RegistViewController2.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/15.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "RegistViewController2.h"
#import "RegistViewController3.h"
#import "SelectTimeView.h"
#import "SelectAddressView.h"
#import "DataService.h"

@interface RegistViewController2 ()<UITextFieldDelegate>{
    
    SelectTimeView *selectTimeView;
    SelectAddressView *selectAddressView;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeDesignationTextField;
@property (weak, nonatomic) IBOutlet UILabel *inDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *outLabel;


@end

@implementation RegistViewController2

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    if([self.source isEqualToString:@"查找"]){
        [self.nextBtn setTitle:@"查找" forState:UIControlStateNormal];
        self.title = @"按条件查找战友";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneTextField.text = self.phone;
}
- (IBAction)nextBtnAction:(UIButton *)sender {
    
    if ([self.source isEqualToString:@"查找"]) {
        
        NSArray * paramArr =@[@{@"username":self.nameTextField.text
                              ,@"phone":self.phoneTextField.text
                              ,@"team_num":self.codeDesignationTextField.text
                              ,@"join_time":[self stringToTimestamp:self.inDataLabel.text]
                              ,@"exit_time":[self stringToTimestamp:self.outLabel.text]
                                ,@"place":self.addressLabel.text}];
        
        NSData *paramArrData=[NSJSONSerialization dataWithJSONObject:paramArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString *paramArrDataJson=[[NSString alloc]initWithData:paramArrData encoding:NSUTF8StringEncoding];
        
        NSDictionary * paramDic =@{@"uid":@"3",@"condition":paramArrDataJson};
        [DataService requestWithPostUrl:@"/api/user/searchFirend" params:paramDic block:^(id result) {
            if (result) {
                NSLog(@"%@",result);
                if(self.passValueBlock) self.passValueBlock([[result objectForKey:@"data"] objectForKey:@"list"]);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        
        NSDictionary * paramDic = @{@"uid":@"3"
                                        ,@"phone":self.phoneTextField.text
                                        ,@"username":self.nameTextField.text
                                        ,@"team_num":self.codeDesignationTextField.text
                                        ,@"join_time":[self stringToTimestamp:self.inDataLabel.text]
                                        ,@"exit_time":[self stringToTimestamp:self.outLabel.text]
                                        ,@"place":self.addressLabel.text};
        
        
            [DataService requestWithPostUrl:@"/api/login/saveinfo" params:paramDic block:^(id result) {
        
                if ([[result objectForKey:@"status"] intValue] == 0) {
                    if (self->_returnToSession) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        RegistViewController3 * regist3 = [[UIStoryboard storyboardWithName:@"LoginRegist" bundle:nil] instantiateViewControllerWithIdentifier:@"regist3"];
                        [self.navigationController pushViewController:regist3 animated:YES];
                    }
                }else{
                    [self showTextMessage:[result objectForKey:@"message"]];
                }
            }];
    }
}


- (IBAction)addressBtnAction:(id)sender {
    [self.view endEditing:YES];
    if (selectTimeView) {
        [selectTimeView removeFromSuperview];
        selectTimeView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_data object:nil];
    }
    if (!selectAddressView) {
        selectAddressView = [[SelectAddressView alloc]initWithFrame:CGRectMake(0, k_screen_height*2/3-40, k_screen_width, k_screen_height/3+40)];
        [selectAddressView creatAddressView];
        [self.view addSubview:selectAddressView];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAddress:) name:notification_address object:nil];
    }
}
-(void)getAddress:(NSNotification*) notification{

    self.addressLabel.text = [notification.userInfo objectForKey:notification_address_key];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_address object:nil];
    [selectAddressView removeFromSuperview];
    selectAddressView = nil;
}
- (IBAction)inDataBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (selectAddressView) {
        [selectAddressView removeFromSuperview];
        selectAddressView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_address object:nil];
    }
    if (selectTimeView) {
        [selectTimeView removeFromSuperview];
        selectTimeView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_data object:nil];
    }
    selectTimeView = [[SelectTimeView alloc]initWithFrame:CGRectMake(0, k_screen_height*2/3-40, k_screen_width, k_screen_height/3+40)];
    [selectTimeView creatTimeView];
    [self.view addSubview:selectTimeView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getInDataTime:) name:notification_data object:nil];
}
-(void)getInDataTime:(NSNotification*) notification{
    
    self.inDataLabel.text = [notification.userInfo objectForKey:notification_data_key];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_data object:nil];
    [selectTimeView removeFromSuperview];
    selectTimeView = nil;
}
- (IBAction)outDataBtnAction:(id)sender {
    [self.view endEditing:YES];
    if (selectAddressView) {
        [selectAddressView removeFromSuperview];
        selectAddressView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_address object:nil];
    }
    if (selectTimeView) {
        [selectTimeView removeFromSuperview];
        selectTimeView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_data object:nil];
    }
    selectTimeView = [[SelectTimeView alloc]initWithFrame:CGRectMake(0, k_screen_height*2/3-40, k_screen_width, k_screen_height/3+40)];
    [self.view addSubview:selectTimeView];
    [selectTimeView creatTimeView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getOutDataTime:) name:notification_data object:nil];
}
-(void)getOutDataTime:(NSNotification*) notification{
    
    self.outLabel.text = [notification.userInfo objectForKey:notification_data_key];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_data object:nil];
    [selectTimeView removeFromSuperview];
    selectTimeView = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (selectAddressView) {
        [selectAddressView removeFromSuperview];
        selectAddressView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_address object:nil];
    }
    if (selectTimeView) {
        [selectTimeView removeFromSuperview];
        selectTimeView = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self name:notification_data object:nil];
    }
    
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_phoneTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_codeDesignationTextField resignFirstResponder];
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
