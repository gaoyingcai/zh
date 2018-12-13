//
//  MainTabBarController.m
//  JuMin
//
//  Created by 管理员 on 2017/8/31.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import "MainTabBarController.h"
#import "HomeViewController.h"
#import "SessionViewController.h"
//#import "NIMSessionListViewController.h"
#import "CircleViewController.h"
#import "UserViewController.h"
#import "AddFriendViewController.h"
@interface MainTabBarController (){
    NSInteger badge;
}
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatControllers];
    
}
-(void)creatControllers{
    //会话
    SessionViewController*session=[[UIStoryboard storyboardWithName:@"Session" bundle:nil] instantiateViewControllerWithIdentifier:@"session"];
    //寻找战友
    AddFriendViewController *add = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"addFriend"];
    //通讯录
    HomeViewController * home = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"home"];
    
    
    
//    NIMSessionListViewController *session = [[NIMSessionListViewController alloc]init];
    //战友圈
    CircleViewController*circle=[[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"circle"];
//    UserViewController*user=[[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"user"];
    
    
//    home.title=@"首页";
//    session.title=@"会话";
//    circle.title=@"战友圈";
//    user.title=@"我的";
    
    UINavigationController*navSession=[[UINavigationController alloc]initWithRootViewController:session];
    UINavigationController*navAdd=[[UINavigationController alloc]initWithRootViewController:add];
    UINavigationController*navHome=[[UINavigationController alloc]initWithRootViewController:home];
    
    UINavigationController*navCircle=[[UINavigationController alloc]initWithRootViewController:circle];
//    UINavigationController*navUser=[[UINavigationController alloc]initWithRootViewController:user];

    self.viewControllers=@[navSession,navAdd,navHome,navCircle];
    [self creatTabBar];
    
}
-(void)creatTabBar{
    
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];//导航栏返回按钮颜色
    [self.tabBar setTintColor:[UIColor blackColor]];//选中状态颜色
    self.tabBar.barTintColor=[UIColor whiteColor];//tabbar背景颜色
    
    self.tabBar.layer.shadowColor=[UIColor blackColor].CGColor;
    self.tabBar.layer.shadowOffset=CGSizeMake(0, -2);
    self.tabBar.layer.shadowOpacity=0.15;
    self.tabBar.layer.shadowRadius=2;
    
    for (UIView*view in self.tabBar.subviews) {
        [view removeFromSuperview];
    }

    NSArray*titles=@[@"会话",@"寻找战友",@"通讯录",@"战友圈"];
    NSArray*normalImgNames=@[@"session_1@2x.png",@"user_1@2x.png",@"home_1@2x.png",@"circle_1@2x.png"];
    NSArray*selectImgNames=@[@"session@2x.png",@"user@2x.png",@"home@2x.png",@"circle@2x.png"];
    
    for (UINavigationController*nvc in self.viewControllers) {
        NSInteger index=[self.viewControllers indexOfObject:nvc];
        
        NSString*title=[titles objectAtIndex:index];
        UIImage*normalImg=[UIImage imageNamed:[normalImgNames objectAtIndex:index]];
        UIImage*selectImg=[UIImage imageNamed:[selectImgNames objectAtIndex:index]];
        selectImg=[selectImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//防止被渲染成蓝色
        UINavigationController*nav=[self.viewControllers objectAtIndex:index];
        /*
         1.设置导航条navigationBar的颜色 (barTintColor和tintColor 的差别)
         self.navigationController.navigationBar.barTintColor =[UIColor blueColor];
         2.设置导航条navigationBar上“按钮”和“字体”的颜色(例:左返回、右添加、左边字体、右边字体)
         self.navigationController.navigationBar.tintColor = [UIColor blackColor];
         3.设置导航条上标题(title)的颜色---(title的属性方法)
         [self.navigationController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
         ---------------------
         原文：https://blog.csdn.net/wyz670083956/article/details/52252023?utm_source=copy
         */
        nav.navigationBar.barTintColor=[UIColor whiteColor];
        nav.navigationBar.tintColor = [UIColor blackColor];
        [nav.navigationBar setTitleTextAttributes:
            @{NSFontAttributeName:[UIFont systemFontOfSize:19],
           NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        UITabBarItem*tabBarItem=[[UITabBarItem alloc]initWithTitle:title image:normalImg selectedImage:selectImg];
        [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: color_green} forState:UIControlStateSelected];
        nav.tabBarItem=tabBarItem;
        
        if (index==2&&badge>0) {
            nav.tabBarItem.badgeValue=[NSString stringWithFormat:@"%ld",(long)badge];
        }
    }
}
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
