//
//  PayViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/15.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "PayViewController.h"
#import "DataService.h"
#import "WXApi.h"

@interface PayViewController ()

@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)payBtnAction:(id)sender {
    NSLog(@"微信支付");
    
    //获取支付金额
    NSDictionary * paramDic = @{@"field":@"reg_money"};
    [DataService requestWithPostUrl:@"api/config/getConfig" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            [self pay:[[result objectForKey:@"data"] objectForKey:@"money"]];
        }
    }];
}

-(void)pay:(NSString*)payMoney{
    //支付
    NSDictionary *paramDic = @{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"],
                               @"money":payMoney,
                               @"suid":@"0",
                               @"info_id":@"0",
                               @"type":@"2",
                               };
    
    [DataService requestWithPostUrl:@"/api/payment/payOrder" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            [self setOrderString:[result objectForKey:@"data"]];
        }
    }];
}
-(void)setOrderString:(NSDictionary*)dic{
    
    if ([dic objectForKey:@"partnerid"]) {

        PayReq *request = [[PayReq alloc] init];
        request.partnerId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"partnerid"]];
        request.prepayId= [NSString stringWithFormat:@"%@",[dic objectForKey:@"prepayid"]];
        request.package = @"Sign=WXPay";
        request.nonceStr= [NSString stringWithFormat:@"%@",[dic objectForKey:@"noncestr"]];
        request.timeStamp= [[dic objectForKey:@"timestamp"] intValue];
        request.sign= [NSString stringWithFormat:@"%@",[dic objectForKey:@"sign"]];
        [WXApi sendReq:request];
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
