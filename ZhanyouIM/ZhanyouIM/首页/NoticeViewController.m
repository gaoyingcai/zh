//
//  NoticeViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "NoticeViewController.h"
#import "HomeCell.h"
#import <NIMSDK/NIMSDK.h>
#import "UIImageView+WebCache.h"

@interface NoticeViewController ()<NIMSystemNotificationManagerDelegate,NIMSystemNotificationManagerDelegate,NIMTeamManagerDelegate>
@property (nonatomic,strong)    NSMutableArray  *notificationArr;
@property (nonatomic,assign)    BOOL shouldMarkAsRead;
@property (nonatomic,strong)    UITableView *tableView;

@end

@implementation NoticeViewController

static int MaxNotificationCount =10;

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

- (void)loadMore:(id)sender
{
    NSArray *notifications = [[[NIMSDK sharedSDK] systemNotificationManager] fetchSystemNotifications:[_notificationArr lastObject]limit:MaxNotificationCount];
    if ([notifications count])
    {
        [_notificationArr addObjectsFromArray:notifications];
        [self.tableView reloadData];
    }
}

- (void)clearAll:(id)sender
{
    [[[NIMSDK sharedSDK] systemNotificationManager] deleteAllNotifications];
    [_notificationArr removeAllObjects];
    [self.tableView reloadData];
    
}

- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification
{
    [_notificationArr insertObject:notification atIndex:0];
    _shouldMarkAsRead = YES;
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"sessionBadge" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"homeBadge" object:nil userInfo:nil];

    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    
    self.navigationItem.title = @"验证消息";
    _notificationArr = [NSMutableArray array];
    
    id<NIMSystemNotificationManager> systemNotificationManager = [[NIMSDK sharedSDK] systemNotificationManager];
    [systemNotificationManager addDelegate:self];
    
    NSArray *notifications = [systemNotificationManager fetchSystemNotifications:nil limit:MaxNotificationCount];
    
    
    if ([notifications count])
    {
        if (![[notifications firstObject] read])
        {
            _shouldMarkAsRead = YES;
        }
        
        NSMutableArray * repeatNotifations = [NSMutableArray arrayWithCapacity:0];
        for (int i =0; i<notifications.count; i++) {
            NIMSystemNotification * notifation1 = notifications[i];
            NIMUserAddAttachment *attachment1 = (NIMUserAddAttachment*)notifation1.attachment;
            if (i+1<notifications.count) {
                for (int j = i+1; j< notifications.count; j++) {
                    NIMSystemNotification * notifation2 = notifications[i];
                    NIMUserAddAttachment *attachment2 = (NIMUserAddAttachment*)notifation2.attachment;
                    if (notifation1.sourceID == notifation2.sourceID&& attachment1.operationType == attachment2.operationType) {
                        [repeatNotifations addObject:notifation1];
                        notifation2.read = YES;
                    }
                }
            }
        }
        [_notificationArr addObjectsFromArray:notifications];
        [_notificationArr removeObjectsInArray:repeatNotifations];
    }
    
   
    
    
    
    if (notifications.count >= MaxNotificationCount) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(0, 0, 320, 40)];
        [button addTarget:self
                   action:@selector(loadMore:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"载入更多" forState:UIControlStateNormal];
        self.tableView.tableFooterView = button;
    }else{
        self.tableView.tableFooterView = [[UIView alloc] init];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空"style:UIBarButtonItemStylePlain target:self action:@selector(clearAll:)];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    
//    NTESSystemNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//    NIMSystemNotification *notification = [_notifications objectAtIndex:[indexPath row]];
//    [cell update:notification];
//    cell.actionDelegate = self;
//    return cell;
    
    //指定cell的重用标识符
    static NSString *reuseIdentifier = @"HOMENOTICE";
    //去缓存池找名叫reuseIdentifier的cell
    //这里换成自己定义的cell
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    //如果缓存池中没有,那么创建一个新的cell
    if (!cell) {
        //这里换成自己定义的cell,并调用类方法加载xib文件
        cell = [HomeCell homeNoticeCell];
    }
    //给cell赋值
    NIMSystemNotification * notifation = [_notificationArr objectAtIndex:indexPath.row];
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:notifation.sourceID];
    NSLog(@"%@",notifation.targetID);
    NSLog(@"%@",notifation.sourceID);
    NIMUserAddAttachment *attachment = (NIMUserAddAttachment*)notifation.attachment;
    NSLog(@"%ld",(long)attachment.operationType);
    switch (attachment.operationType) {
        case 3:
            [cell.accessBtn setTitle:@"已同意" forState:UIControlStateNormal];
            [cell.accessBtn setTitleColor:RGBACOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
            cell.accessBtn.backgroundColor = [UIColor clearColor];
            cell.accessBtnRight.constant -= 41;
            cell.accessBtn.userInteractionEnabled = NO;
            cell.refusedBtn.hidden = YES;
            break;
        case 4:
            [cell.refusedBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
            [cell.refusedBtn setTitleColor:RGBACOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
            cell.refusedBtn.backgroundColor = [UIColor clearColor];
            cell.refusedBtnRight.constant += 41;
            cell.refusedBtn.userInteractionEnabled = NO;
            cell.accessBtn.hidden = YES;
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.text =user.userInfo.nickName;
    cell.checkTextLabel.text = notifation.postscript;
    cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgView.layer.masksToBounds =YES;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:domain_img(user.userInfo.avatarUrl)]];
    cell.accessBtn.tag = indexPath.row;
    [cell.accessBtn addTarget:self action:@selector(accessBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.refusedBtn.tag = indexPath.row;
    [cell.refusedBtn addTarget:self action:@selector(refusedBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //返回当前cell
    return cell;
}
-(void)accessBtnAction:(UIButton *)button{
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    NIMSystemNotification * notification = [_notificationArr objectAtIndex:button.tag];
    request.userId = notification.sourceID;
    request.operation = NIMUserOperationVerify;
    [[[NIMSDK sharedSDK] userManager]requestFriend:request completion:^(NSError * _Nullable error) {
        if (error != nil) {
            [self showTextMessage:[NSString stringWithFormat:@"%@",error]];
        }else{
            [[[NIMSDK sharedSDK] systemNotificationManager] deleteNotification:notification];
            [self->_notificationArr removeObjectAtIndex:button.tag];
            [self.tableView reloadData];
        }
    }];
}
-(void)refusedBtnAction:(UIButton *)button{
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    NIMSystemNotification * notification = [_notificationArr objectAtIndex:button.tag];
    request.userId = notification.sourceID;
    request.operation = NIMUserOperationReject;
    [[[NIMSDK sharedSDK] userManager]requestFriend:request completion:^(NSError * _Nullable error) {
        if (error != nil) {
            [self showTextMessage:[NSString stringWithFormat:@"%@",error]];
        }else{
            [[[NIMSDK sharedSDK] systemNotificationManager] deleteNotification:notification];
            [self->_notificationArr removeObjectAtIndex:button.tag];
            [self.tableView reloadData];
        }
    }];
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_notificationArr count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger index = [indexPath row];
        NIMSystemNotification *notification = [_notificationArr objectAtIndex:index];
        [_notificationArr removeObjectAtIndex:index];
        [[[NIMSDK sharedSDK] systemNotificationManager] deleteNotification:notification];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - SystemNotificationCell
- (void)onAccept:(NIMSystemNotification *)notification
{
    NSLog(@"%@",notification);
}

- (void)onRefuse:(NIMSystemNotification *)notification
{
    NSLog(@"%@",notification);
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
