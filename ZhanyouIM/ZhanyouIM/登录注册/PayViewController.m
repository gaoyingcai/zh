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
#import "UIViewController+BackButtonHandler.h"

@interface PayViewController (){
    NSString *payMoney;
//    BOOL isCanSideBack;
}
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (nonatomic) BOOL isCanSideBack;

@end

@implementation PayViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取支付金额
    NSDictionary * paramDic = @{@"field":@"reg_money"};
    [DataService requestWithPostUrl:@"api/config/getConfig" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            self->payMoney = [[result objectForKey:@"data"] objectForKey:@"money"];
            self.moneyLabel.text = [NSString stringWithFormat:@"￥%@",[[result objectForKey:@"data"] objectForKey:@"money"]];
        }
    }];
}
- (IBAction)payBtnAction:(id)sender {
    NSLog(@"微信支付");
    //支付
    NSDictionary *paramDic = @{@"uid":[[self getUserinfo] objectForKey:@"uid"],
                               @"money":payMoney,
                               @"type":self.type,
                               @"suid":@"0"
                               };
    
    [DataService requestWithPostUrl:@"/api/payment/payOrder" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self setOrderString:[result objectForKey:@"data"]];
        }
    }];
}
-(void)setOrderString:(NSDictionary*)dic{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccess) name:@"ORDER_PAY_NOTIFICATION" object:nil];
    
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
-(void)paySuccess{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ORDER_PAY_NOTIFICATION" object:nil];
//    if (_returnToSession) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

-(BOOL)navigationShouldPopOnBackButton{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"巨资投入,请战友共同维护!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
//    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"确定"];
//    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:color_green range:NSMakeRange(0, 2)];
//    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 2)];
//
//
//    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",alertControllerStr] style:UIActionSheetStyleDefault handler:nil];
//    [defaultAction setValue:alertControllerStr forKey:@"attributedTitle"];

    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    [alertController addAction:defaultAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return YES;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resetSideBack];
}
/**
 *恢复边缘返回
 */
- (void)resetSideBack {
    
    self.isCanSideBack=YES;
    //开启ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isCanSideBack = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    return self.isCanSideBack;
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
