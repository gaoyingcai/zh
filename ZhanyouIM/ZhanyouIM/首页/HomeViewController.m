//
//  HomeViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/13.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCell.h"
#import "LoginViewController.h"
#import "NoticeViewController.h"
#import "AddFriendViewController.h"
#import "NewGroupViewController.h"
#import "DataService.h"
#import "UIImageView+WebCache.h"
#import "NIMSessionViewController.h"
#import "NIMSessionListViewController.h"
#import "MYSessionViewController.h"
#import "WebViewController.h"
#import "UserViewController.h"
#import "AppDelegate.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,NIMLoginManagerDelegate>{
    
    UIView *backView;
    NSMutableArray * friendArr;//会话
    NSMutableArray * groupArr;//群聊
    
    UITableView * friendTableView;
    UITableView * groupTableView;
    
    NSMutableDictionary * announcementDic;
}

@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationItem setHidesBackButton:YES];
    self.tabBarController.tabBar.hidden = NO;
    [_addView setHidden:YES];
    if (self.scrollView.contentOffset.x < k_screen_width/2) {
        [self friendBtnAction:nil];
    }else{
        [self groupBtnAction:nil];
    }
}
-(void)getUserInfo{

    [DataService requestWithPostUrl:@"/api/common/getIndexData" params:@{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"]} block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            self->announcementDic = [NSMutableDictionary dictionaryWithDictionary:[[result objectForKey:@"data"]objectForKey:@"notice"]];
            NSDictionary *userInfo = [[result objectForKey:@"data"]objectForKey:@"userInfo"];

//            NSString *urlStr = domain_img([userInfo objectForKey:@"head_url"]);
//            [self.userImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
            int star_num = [[userInfo objectForKey:@"star"] intValue];
            if (star_num == 0) {
                star_num = 1;
            }

            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setBadge:) name:@"homeBadge" object:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"homeBadge" object:nil userInfo:nil];

    
    
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftBtn.frame = CGRectMake(0, 0, 25, 25);
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"user_info.png"] forState:UIControlStateNormal];
//    [leftBtn addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:leftBtn]];

    
    NSMutableDictionary * userDic =[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user];
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 36, 36);
    leftBtn.layer.cornerRadius = 18;
    leftBtn.layer.masksToBounds = YES;
    dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:domain_img([userDic objectForKey:@"userImg"])]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [leftBtn setBackgroundImage:[self reSizeImage:img toSize:leftBtn.size] forState:UIControlStateNormal];
        });
        
    });
    [leftBtn addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:leftBtn]];
    
    
    [self getUserInfo];
    
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.contentSize = CGSizeMake(k_screen_width*2, 0);
    
    for (int i=0; i<2; i++) {
        UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(k_screen_width*i, 0, k_screen_width, k_view_height(self.scrollView)) style:UITableViewStylePlain];
        tableView.tag = i;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = color_lightGray;
        [self.scrollView addSubview:tableView];
        if (i == 0) {
            friendTableView = tableView;
        }else{
            groupTableView = tableView;
        }
    }
    friendTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    groupTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)setBadge:(NSNotification*)sender{
    self.navigationItem.rightBarButtonItem = nil;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 25, 25);
    if (sender.userInfo) {
        [btn setBackgroundImage:[UIImage imageNamed:@"tianjia_badge@2x.png"] forState:UIControlStateNormal];
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"tianjia@2x.png"] forState:UIControlStateNormal];
    }
    [btn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
}
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}
-(void)showUserInfo:(UIButton*)btn{
    UserViewController* userView = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"user"];
//    userInfo.phone = [[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"phone"];
//    userInfo.loginOut=YES;
    [self.navigationController pushViewController:userView animated:YES];
    
}
    
-(void)addBtnAction:(UIButton*)btn{
    
    if (backView == nil) {
        backView = [[UIView alloc]initWithFrame:self.view.frame];
        backView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:backView];
        [self.view bringSubviewToFront:_addView];
    }
    
    if (_addView.hidden) {
        [_addView setHidden:NO];
    }else{
        [_addView setHidden:YES];
    }
}
- (IBAction)addButtonsAction:(UIButton *)sender {

    if (sender.tag == 1) {
        NSLog(@"通知");
        NoticeViewController * notice = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"notice"];
        [self.navigationController pushViewController:notice animated:YES];
    }else if (sender.tag == 2){
        NSLog(@"添加战友");
        AddFriendViewController * addFriend = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"addFriend"];
        [self.navigationController pushViewController:addFriend animated:YES];
    }else if (sender.tag == 3){
        NSLog(@"新建群聊");
        NewGroupViewController * newGroup = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"newGroup"];
        [self.navigationController pushViewController:newGroup animated:YES];
    }
}
- (IBAction)friendBtnAction:(UIButton *)sender {
    [self.friendBtn setTitleColor:color_green forState:UIControlStateNormal];
    self.friendLine.backgroundColor = color_green;
    [self.groupBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.groupLine.backgroundColor = [UIColor clearColor];
    self.scrollView.contentOffset=CGPointMake(0, 0);

    friendArr = [NSMutableArray arrayWithArray:[NIMSDK sharedSDK].userManager.myFriends];
    if (!friendArr.count) {
        [self addQueshengImageToView:friendTableView imageName:@"zhanyou@2x.png"hidden:NO];
    }else{
        NSMutableArray * myFriendArray = [NSMutableArray arrayWithCapacity:0];
        for (NIMUser *user in friendArr) {
            [myFriendArray addObject:user.userId];
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:myFriendArray forKey:@"MyFriend"];
        [self addQueshengImageToView:friendTableView imageName:@"zhanyou@2x.png"hidden:YES];
    }
    [friendTableView reloadData];
}
- (IBAction)groupBtnAction:(UIButton *)sender {
    [self.friendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.friendLine.backgroundColor = [UIColor clearColor];
    [self.groupBtn setTitleColor:color_green forState:UIControlStateNormal];
    self.groupLine.backgroundColor = color_green;
    
    
    
    self.scrollView.contentOffset=CGPointMake(k_screen_width, 0);
    groupArr = [NSMutableArray arrayWithArray: [[NIMSDK sharedSDK].teamManager allMyTeams]];
    if (!groupArr.count) {
        [self addQueshengImageToView:groupTableView imageName:@"zhanyou@2x.png"hidden:NO];
    }else{
        [self addQueshengImageToView:groupTableView imageName:@"zhanyou@2x.png"hidden:YES];
    }
    [groupTableView reloadData];

}
- (IBAction)announcementBtnAction:(id)sender {
    NSLog(@"公告");
    /*
     {
     "notice_url" = "http://aiwozhonghua.kh.juanyunkeji.cn/zt/notice.html";
     status = 1;
     title = "\U6cd5\U7b2c\U4e09\U65b9";
     };
     */
    WebViewController *webView = [[WebViewController alloc]init];
    webView.title = [announcementDic objectForKey:@"title"];
    webView.webViewStr = [announcementDic objectForKey:@"notice_url"];
//    webView.webViewStr = @"https://www.baidu.com/";
    [self.navigationController pushViewController:webView animated:YES];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.state != 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    //![scrollView isKindOfClass:[UITableView class]] &&
    if (![scrollView isKindOfClass:[UITableView class]]) {
        if (scrollView.contentOffset.x < k_screen_width/2) {
            [self friendBtnAction:nil];
        }else{
            [self groupBtnAction:nil];
        }
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //指定cell的重用标识符
    static NSString *reuseIdentifier = @"HOMEBASE";
    //去缓存池找名叫reuseIdentifier的cell
    //这里换成自己定义的cell
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //如果缓存池中没有,那么创建一个新的cell
    if (!cell) {
        //这里换成自己定义的cell,并调用类方法加载xib文件
        cell = [HomeCell homeBaseCell];
    }
    //给cell赋值
    
//    NIMRecentSession * recentSession;
    if (tableView.tag == 0) {
        NIMUser* user = [friendArr objectAtIndex:indexPath.row];
        cell.nameLabel.text =user.userInfo.nickName;
        if (![user.userInfo.avatarUrl isKindOfClass:[NSNull class]]) {
            cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imgView.layer.masksToBounds =YES;
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:domain_img(user.userInfo.avatarUrl)]];
        }
    }else{
        NIMTeam *team = [groupArr objectAtIndex:indexPath.row];
        cell.nameLabel.text =team.teamName;
        if (![team.avatarUrl isKindOfClass:[NSNull class]]) {
            cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imgView.layer.masksToBounds =YES;
//            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:domain_img(team.avatarUrl)]];
            cell.imgView.image = [UIImage imageNamed:@"qunzu@2x.png"];
        }
    }
    //返回当前cell
    return cell;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return friendArr.count;
    }
    return groupArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 0) {
        NIMUser *user = [friendArr objectAtIndex:indexPath.row];
        NIMSession *session = [NIMSession session:user.userId type:NIMSessionTypeP2P];
        MYSessionViewController *sessionVc = [[MYSessionViewController alloc] initWithSession:session];
        sessionVc.phone =user.userInfo.mobile;
        NSLog(@"%@",user.userId);
        NSLog(@"%@",user.userInfo.mobile);
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:sessionVc animated:YES];

    }else{
        NIMTeam *team = [groupArr objectAtIndex:indexPath.row];
        NIMSession *session = [NIMSession session:team.teamId type:NIMSessionTypeTeam];
        MYSessionViewController *sessionVc = [[MYSessionViewController alloc] initWithSession:session];
//        sessionVc.phone =user.userInfo.mobile;
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:sessionVc animated:YES];

    }
    
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_addView.hidden) {
        [_addView setHidden:YES];
    }
    [backView removeFromSuperview];
    backView =nil;
}
@end
