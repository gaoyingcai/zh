//
//  WebViewController.m
//  JuMin
//
//  Created by 管理员 on 2017/9/13.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
@interface WebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
{
    WKWebView*_webView;
}

@end

@implementation WebViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
//    self.navigationController.navigationBar.hidden=YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
//    [self setSlidBack];
    
//    UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, k_star_width, 20)];
//    statusBarView.backgroundColor=RGBACOLOR(34, 213, 202, 1);
//    [self.view addSubview:statusBarView];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    _webView=[[WKWebView alloc]initWithFrame:CGRectMake(0, 20, k_screen_width, k_screen_height)];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webViewStr]]];
    [self.view addSubview:_webView];
    
    _webView.navigationDelegate=self;//
    _webView.UIDelegate=self;//这个协议主要用于WKWebView处理web界面的三种提示框(警告框、确认框、输入框)
    
//    [[_webView configuration].userContentController addScriptMessageHandler:self name:@"closebrowser"];
    
}

#pragma -mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"开始调用");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"内容开始返回");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"加载完成");
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"加载失败");
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
//     NSLog(@"JS 调用了 %@ 方法，传回参数 %@",message.name,message.body);
    [self.navigationController popViewControllerAnimated:NO];
}

















//-(void)close{
//    [self.navigationController popViewControllerAnimated:NO];
//}
//- (void)userContentController:(WKUserContentController *)userContentController
//      didReceiveScriptMessage:(WKScriptMessage *)message {
//    if ([message.name isEqualToString:@"AppModel"]) {
//        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
//        // NSDictionary, and NSNull类型
//        NSLog(@"%@", message.body);
//    }
//}
//
////-(void)webViewDidStartLoad:(UIWebView *)webView{
////    NSLog(@"网页开始加载");
////}
//-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    
//    NSLog(@"加载完成");
//    
////      //******************OC执行JS方法*************//
//////    NSString*alertJS=@"execJavascript('ios')";//准备执行的js代码
//////    [webView stringByEvaluatingJavaScriptFromString:alertJS];  //运行js中的方法
////    
////    //*****************JS调用OC方法*******************//
////    JSContext*context=[_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
////    
////    context[@"closebrowser"]= ^(){
////        
//////        NSArray *args = [JSContext currentArguments];//参数**得到的是所有的参数数组
//////        NSLog(@"%@",args);
////        
////        dispatch_async(dispatch_get_main_queue(),^{
////            [self.navigationController popViewControllerAnimated:NO];
////        });
//////        return 1;
////    };
//////
//    
//}
////// 页面加载完成之后调用
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    
//    NSLog(@"加载完成");
//    
//    //******************OC执行JS方法*************//
//    //    NSString*alertJS=@"execJavascript('ios')";//准备执行的js代码
//    //    [webView stringByEvaluatingJavaScriptFromString:alertJS];  //运行js中的方法
//    
////    //*****************JS调用OC方法*******************//
////    JSContext*context=[_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
////    
////    context[@"closebrowser"]= ^(){
////        
////        //        NSArray *args = [JSContext currentArguments];//参数**得到的是所有的参数数组
////        //        NSLog(@"%@",args);
////        
////        dispatch_async(dispatch_get_main_queue(),^{
////            [self.navigationController popViewControllerAnimated:NO];
////        });
////        //        return 1;
////    };
////    //
//    
////    [[_webView configuration].userContentController addScriptMessageHandler:self name:@"closebrowser"];
//    
//
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
