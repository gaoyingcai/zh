//
//  AppDelegate.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/11.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import <NIMSDK/NIMSDK.h>
#import <NIMSDK/NIMSDKOption.h>


@interface AppDelegate ()<NIMSystemNotificationManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

//    [NSThread sleepForTimeInterval:3.5];
    
    [WXApi registerApp:@"wx1f997c650f37820d"];
    
    
    //4d3fd964f78d
    //推荐在程序启动的时候初始化 NIMSDK
    NSString *appKey        = @"98a51dd54e15912adb7b21a09c5f79c0";
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
//    option.apnsCername      = @"your APNs cer name";
//    option.pkCernam         = @"your pushkit cer name";
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    
//    NIMServerSetting *setting    = [[NIMServerSetting alloc] init];
//    setting.enabledHttps = YES;
//    [[NIMSDK sharedSDK] setServerSetting:setting];
    

//    App Key：98a51dd54e15912adb7b21a09c5f79c0
//    App Secret：b8f9712ccc30
    
    
//    NSDictionary * dic =[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
//    NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
//    loginData.account = [dic objectForKey:@"accid"];
//    loginData.token = [dic objectForKey:@"token"];
//    [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
//    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];

    
    
    //全局监听好友请求
//    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    
    
    
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    MainTabBarController*tabBar=[[MainTabBarController alloc]init];
    self.window.rootViewController=tabBar;
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"1");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSNotification *notification = [NSNotification notificationWithName:@"ORDER_PAY_NOTIFICATION" object:@"success"];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    NSLog(@"1");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    // 其他如支付等SDK的回调
//    if ([url.host isEqualToString:@"safepay"]) {
//        //跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//        }];
//    }
//
    if ([url.scheme isEqualToString:@"wx710fe180b56b6dd1"])
    {
        return  [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self];
    }
    return YES;
}

- (void)onResp:(BaseResp *)resp {
    //    支付结果回调
    if([resp isKindOfClass:[PayResp class]]){
        switch (resp.errCode) {
            case WXSuccess:{
                //支付返回结果，实际支付结果需要去自己的服务器端查询
                NSNotification *notification = [NSNotification notificationWithName:@"ORDER_PAY_NOTIFICATION" object:@"success"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                break;
            }
            default:{
                NSNotification *notification = [NSNotification notificationWithName:@"ORDER_PAY_NOTIFICATION"object:@"fail"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                break;
            }
        }
    }
}

//- (void)onLogin:(NIMLoginStep)step{
//    NSLog(@"%ld",(long)step);
//    if (step == NIMLoginStepLoginOK) {
//        NSLog(@"登录成功");
//    }else if (step == NIMLoginStepLoginFailed || step == NIMLoginStepLoseConnection || step == NIMLoginStepNetChanged){
//
//        NSDictionary * dic =[[NSUserDefaults standardUserDefaults]objectForKey:user_defaults_user];
//        NSString *account = [dic objectForKey:@"accid"];
//        NSString *token   = [dic objectForKey:@"token"];
//        [[[NIMSDK sharedSDK] loginManager] login:account
//                                           token:token
//                                      completion:^(NSError *error) {
//                                          NSLog(@"%@",error);
//                                      }];
//        NSLog(@"已经退出登录");
//    }
//}


@end
