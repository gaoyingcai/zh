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
    
    
    
//    _notificationArr = [NSMutableArray arrayWithArray:[[NIMSDK sharedSDK].systemNotificationManager fetchSystemNotifications:nil limit:10]];
//
//
//    NIMSystemNotificationFilter *fielter =[[NIMSystemNotificationFilter alloc]init];
//    NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
//    [array addObject: [NSNumber numberWithInt:5]];
//    fielter.notificationTypes = array;
//
//    [[NIMSDK sharedSDK].systemNotificationManager fetchSystemNotifications:nil limit:10 filter: fielter];
//    NSLog(@"%@",_notificationArr);
    
    
    
    
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
        [_notificationArr addObjectsFromArray:notifications];
        if (![[notifications firstObject] read])
        {
            _shouldMarkAsRead = YES;
        }
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
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:notifation.targetID];
    cell.nameLabel.text =user.userInfo.nickName;
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
//    __weak typeof(self) wself = self;
//    switch (notification.type) {
//        case NIMSystemNotificationTypeTeamApply:{
//            [[NIMSDK sharedSDK].teamManager passApplyToTeam:notification.targetID userId:notification.sourceID completion:^(NSError *error, NIMTeamApplyStatus applyStatus) {
//                if (!error) {
//                    [wself.navigationController.view makeToast:@"同意成功"
//                                                      duration:2
//                                                      position:CSToastPositionCenter];
//                    notification.handleStatus = NotificationHandleTypeOk;
//                    [wself.tableView reloadData];
//                }else {
//                    if(error.code == NIMRemoteErrorCodeTimeoutError) {
//                        [wself.navigationController.view makeToast:@"网络问题，请重试"
//                                                          duration:2
//                                                          position:CSToastPositionCenter];
//                    } else {
//                        notification.handleStatus = NotificationHandleTypeOutOfDate;
//                    }
//                    [wself.tableView reloadData];
//                    DDLogDebug(@"%@",error.localizedDescription);
//                }
//            }];
//            break;
//        }
//        case NIMSystemNotificationTypeTeamInvite:{
//            [[NIMSDK sharedSDK].teamManager acceptInviteWithTeam:notification.targetID invitorId:notification.sourceID completion:^(NSError *error) {
//                if (!error) {
//                    [wself.navigationController.view makeToast:@"接受成功"
//                                                      duration:2
//                                                      position:CSToastPositionCenter];
//                    notification.handleStatus = NotificationHandleTypeOk;
//                    [wself.tableView reloadData];
//                }else {
//                    if(error.code == NIMRemoteErrorCodeTimeoutError) {
//                        [wself.navigationController.view makeToast:@"网络问题，请重试"
//                                                          duration:2
//                                                          position:CSToastPositionCenter];
//                    }
//                    else if (error.code == NIMRemoteErrorCodeTeamNotExists) {
//                        [wself.navigationController.view makeToast:@"群不存在"
//                                                          duration:2
//                                                          position:CSToastPositionCenter];
//                    }
//                    else {
//                        notification.handleStatus = NotificationHandleTypeOutOfDate;
//                    }
//                    [wself.tableView reloadData];
//                    DDLogDebug(@"%@",error.localizedDescription);
//                }
//            }];
//        }
//            break;
//        case NIMSystemNotificationTypeFriendAdd:
//        {
//            NIMUserRequest *request = [[NIMUserRequest alloc] init];
//            request.userId = notification.sourceID;
//            request.operation = NIMUserOperationVerify;
//
//            [[[NIMSDK sharedSDK] userManager] requestFriend:request
//                                                 completion:^(NSError *error) {
//                                                     if (!error) {
//                                                         [wself.navigationController.view makeToast:@"验证成功"
//                                                                                           duration:2
//                                                                                           position:CSToastPositionCenter];
//                                                         notification.handleStatus = NotificationHandleTypeOk;
//                                                     }
//                                                     else
//                                                     {
//                                                         [wself.navigationController.view makeToast:@"验证失败,请重试"
//                                                                                           duration:2
//                                                                                           position:CSToastPositionCenter];
//                                                     }
//                                                     [wself.tableView reloadData];
//                                                     DDLogDebug(@"%@",error.localizedDescription);
//                                                 }];
//        }
//            break;
//        default:
//            break;
//    }
}

- (void)onRefuse:(NIMSystemNotification *)notification
{
//    __weak typeof(self) wself = self;
//    switch (notification.type) {
//        case NIMSystemNotificationTypeTeamApply:{
//            [[NIMSDK sharedSDK].teamManager rejectApplyToTeam:notification.targetID userId:notification.sourceID rejectReason:@"" completion:^(NSError *error) {
//                if (!error) {
//                    [wself.navigationController.view makeToast:@"拒绝成功"
//                                                      duration:2
//                                                      position:CSToastPositionCenter];
//                    notification.handleStatus = NotificationHandleTypeNo;
//                    [wself.tableView reloadData];
//                }else {
//                    if(error.code == NIMRemoteErrorCodeTimeoutError) {
//                        [wself.navigationController.view makeToast:@"网络问题，请重试"
//                                                          duration:2
//                                                          position:CSToastPositionCenter];
//                    } else {
//                        notification.handleStatus = NotificationHandleTypeOutOfDate;
//                    }
//                    [wself.tableView reloadData];
//                    DDLogDebug(@"%@",error.localizedDescription);
//                }
//            }];
//        }
//            break;
//
//        case NIMSystemNotificationTypeTeamInvite:{
//            [[NIMSDK sharedSDK].teamManager rejectInviteWithTeam:notification.targetID invitorId:notification.sourceID rejectReason:@"" completion:^(NSError *error) {
//                if (!error) {
//                    [wself.navigationController.view makeToast:@"拒绝成功"
//                                                      duration:2
//                                                      position:CSToastPositionCenter];
//                    notification.handleStatus = NotificationHandleTypeNo;
//                    [wself.tableView reloadData];
//                }else {
//                    if(error.code == NIMRemoteErrorCodeTimeoutError) {
//                        [wself.navigationController.view makeToast:@"网络问题，请重试"
//                                                          duration:2
//                                                          position:CSToastPositionCenter];
//                    }
//                    else if (error.code == NIMRemoteErrorCodeTeamNotExists) {
//                        [wself.navigationController.view makeToast:@"群不存在"
//                                                          duration:2
//                                                          position:CSToastPositionCenter];
//                    }
//                    else {
//                        notification.handleStatus = NotificationHandleTypeOutOfDate;
//                    }
//                    [wself.tableView reloadData];
//                    DDLogDebug(@"%@",error.localizedDescription);
//                }
//            }];
//
//        }
//            break;
//        case NIMSystemNotificationTypeFriendAdd:
//        {
//            NIMUserRequest *request = [[NIMUserRequest alloc] init];
//            request.userId = notification.sourceID;
//            request.operation = NIMUserOperationReject;
//
//            [[[NIMSDK sharedSDK] userManager] requestFriend:request
//                                                 completion:^(NSError *error) {
//                                                     if (!error) {
//                                                         [wself.navigationController.view makeToast:@"拒绝成功"
//                                                                                           duration:2
//                                                                                           position:CSToastPositionCenter];
//                                                         notification.handleStatus = NotificationHandleTypeNo;
//                                                     }
//                                                     else
//                                                     {
//                                                         [wself.navigationController.view makeToast:@"拒绝失败,请重试"
//                                                                                           duration:2
//                                                                                           position:CSToastPositionCenter];
//                                                     }
//                                                     [wself.tableView reloadData];
//                                                     DDLogDebug(@"%@",error.localizedDescription);
//                                                 }];
//        }
//            break;
//        default:
//            break;
//    }
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
