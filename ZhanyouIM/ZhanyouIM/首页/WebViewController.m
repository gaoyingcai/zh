//
//  WebViewController.m
//  JuMin
//
//  Created by 管理员 on 2017/9/13.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "Moment.h"
#import "MMImageListView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>



@interface WebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
//{
//    WKWebView*_webView;
//}
@property (nonatomic,strong)  AVPlayerViewController * PlayerVC;
@property (nonatomic,strong) WKWebView *webview;

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

    if (self.videoStr.length >5) {
        
//        NSMutableArray *array =[NSMutableArray arrayWithObject:@{@"path_source":self.videoStr,@"path_source_img_notice":@""}];
//
//        MMImageListView *imageListView = [[MMImageListView alloc] initWithFrame:CGRectZero];
//        Moment *moment = [[Moment alloc] init];
//        moment.fileCount = 1;
//        moment.imageArray = array;
//        imageListView.moment = moment;
//
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 64, k_screen_width, k_screen_height*9/16)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
//        [view addSubview:imageListView];
//
        self.webview=[[WKWebView alloc]initWithFrame:CGRectMake(0, k_screen_width*9/16+64, k_screen_width, k_screen_height - k_screen_width*9/16 -74)];
        
        
        
        //获取视频尺寸
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.videoStr]];
        NSArray *array = asset.tracks;
        CGSize videoSize = CGSizeZero;
        for (AVAssetTrack *track in array) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                videoSize = track.naturalSize;
            }
        }
//        UIImageView *imageView =[[UIImageView alloc]init];
//        imageView.backgroundColor = [UIColor blackColor];
//        imageView.userInteractionEnabled = YES;
//        CGRect frame = CGRectZero;
//        [view addSubview:imageView];
        
        
        
//        _PlayerVC.player = [AVPlayer playerWithURL:self.videoStr];
//        [self.PlayerVC.player play];
        
        
        _PlayerVC = [[AVPlayerViewController alloc] init];
        
//        _PlayerVC.view.frame = [[UIScreen mainScreen] bounds];
        _PlayerVC.showsPlaybackControls = YES;
        _PlayerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.videoStr]];
        
        
        
//        [app.keyWindow addSubview:self.PlayerVC.view];
        
        if (videoSize.width >0) {
            NSInteger wi = videoSize.width;
            NSInteger he = videoSize.height;
            double hewiScale = (double)he/wi;
            double wiheScale = (double)wi/he;
            
            
            if (hewiScale*16 >9) {
                _PlayerVC.view.frame = CGRectMake(12 + ((k_screen_width -24) -(k_screen_width -24)*9/16 * wiheScale)/2, 0 , (k_screen_width -24)*9/16 * wiheScale, (k_screen_width -24)*9/16);
            }else{
                _PlayerVC.view.frame = CGRectMake(12, 0 , k_screen_width-24, (k_screen_width -24)*hewiScale);
            }
        }
        
        
        [view addSubview:_PlayerVC.view];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapSmallViewVideoPlayer)];
//        [imageView addGestureRecognizer:tap];
        
        
        
        
    }else{
        self.webview=[[WKWebView alloc]initWithFrame:CGRectMake(0, 20, k_screen_width, k_screen_height)];
    }
    
//    self.webview=[[WKWebView alloc]initWithFrame:CGRectMake(0, 20, k_screen_width, k_screen_height)];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webViewStr]]];
    [self.view addSubview:self.webview];
    
    self.webview.navigationDelegate=self;//
    self.webview.UIDelegate=self;//这个协议主要用于WKWebView处理web界面的三种提示框(警告框、确认框、输入框)
}

#pragma mark -视频播放
- (void)singleTapSmallViewVideoPlayer
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.videoStr]];
    _PlayerVC.player = [AVPlayer playerWithURL:url];
    [self.PlayerVC.player play];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, k_screen_height*1/5, k_screen_width, k_screen_height*2/3)];
    [button addTarget:self action:@selector(closeShow:) forControlEvents:UIControlEventTouchUpInside];
    [app.keyWindow addSubview:button];
}
-(AVPlayerViewController*)PlayerVC{
    if (!_PlayerVC) {
        _PlayerVC = [[AVPlayerViewController alloc] init];
        _PlayerVC.view.frame = [[UIScreen mainScreen] bounds];
        _PlayerVC.showsPlaybackControls = YES;
    }
    return _PlayerVC;
}
//关闭显示
- (void)closeShow:(UIButton *)button
{
    if (self.PlayerVC) {
        [self.PlayerVC.player pause];
        self.PlayerVC = nil;
    }
    UIApplication *app = [UIApplication sharedApplication];
    UIView *view = [app.keyWindow.subviews objectAtIndex:1];
    [view removeFromSuperview];
    [button removeFromSuperview];
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
