//
//  NIMSessionViewController.m
//  NIMKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NIMSessionConfigurateProtocol.h"
#import "NIMKit.h"
#import "NIMMessageCellProtocol.h"
#import "NIMMessageModel.h"
#import "NIMKitUtil.h"
#import "NIMCustomLeftBarView.h"
#import "NIMBadgeView.h"
#import "UITableView+NIMScrollToBottom.h"
#import "NIMMessageMaker.h"
#import "NIMKitUIConfig.h"
#import "UIView+NIM.h"
#import "NIMSessionConfigurator.h"
#import "NIMKitInfoFetchOption.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"

@interface NIMSessionViewController ()<NIMMediaManagerDelegate,NIMInputDelegate>

@property (nonatomic,readwrite) NIMMessage *messageForMenu;

@property (nonatomic,strong)    UILabel *titleLabel;

@property (nonatomic,strong)    UILabel *subTitleLabel;

@property (nonatomic,strong)    NSIndexPath *lastVisibleIndexPathBeforeRotation;

@property (nonatomic,strong)  NIMSessionConfigurator *configurator;

@property (nonatomic,weak)    id<NIMSessionInteractor> interactor;

@end

@implementation NIMSessionViewController

- (instancetype)initWithSession:(NIMSession *)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)dealloc
{
    [self removeListener];
    [[NIMKit sharedKit].robotTemplateParser clean];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏
    [self setupNav];
    //消息 tableView
    [self setupTableView];
    //输入框 inputView
    
    if (!_hideInputTextField) {
        [self setupInputView];
    }
    
    //会话相关逻辑配置器安装
    [self setupConfigurator];
    //添加监听
    [self addListener];
    //进入会话时，标记所有消息已读，并发送已读回执
    [self markRead];
    //更新已读位置
    [self uiCheckReceipt];
    //再次刷新
    [self.tableView reloadData];
}

- (void)setupNav
{
    [self setUpTitleView];
    NIMCustomLeftBarView *leftBarView = [[NIMCustomLeftBarView alloc] init];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarView];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)setupTableView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = NIMKit_UIColorFromRGB(0xe4e7ec);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}


- (void)setupInputView
{
    BOOL disableInputView = NO;
    if ([self.sessionConfig respondsToSelector:@selector(disableInputView)]) {
        disableInputView = [self.sessionConfig disableInputView];
    }
    if (!disableInputView) {
        self.sessionInputView = [[NIMInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.nim_width,0) config:self.sessionConfig];
        [self.sessionInputView refreshStatus:NIMInputStatusText];
        [self.sessionInputView setSession:self.session];
        [self.sessionInputView setInputDelegate:self];
        [self.sessionInputView setInputActionDelegate:self];
        [self.view addSubview:_sessionInputView];
        
        self.tableView.nim_height -= self.sessionInputView.toolBar.nim_height;
    }
}


- (void)setupConfigurator
{
    _configurator = [[NIMSessionConfigurator alloc] init];
    [_configurator setup:self];
    
    BOOL needProximityMonitor = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableProximityMonitor)]) {
        needProximityMonitor = !self.sessionConfig.disableProximityMonitor;
    }
    [[NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:needProximityMonitor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.interactor onViewWillAppear];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.interactor onViewDidDisappear];
    
    [self.sessionInputView endEditing:YES];
}


- (void)viewDidLayoutSubviews{
    [self changeLeftBarBadge:self.conversationManager.allUnreadCount];
    [self.interactor resetLayout];
}



#pragma mark - 消息收发接口
- (void)sendMessage:(NIMMessage *)message
{
    [self.interactor sendMessage:message];
}


#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_sessionInputView endEditing:YES];
}


#pragma mark - NIMSessionConfiguratorDelegate

- (void)didFetchMessageData
{
    [self uiCheckReceipt];
    [self.tableView nim_scrollToBottom:NO];
    
//    UIView * keepOutView = [[UIView alloc]initWithFrame:self.view.frame];
//    keepOutView.backgroundColor = [UIColor colorWithRed:228/255.0 green:230/255.0 blue:235/255.0 alpha:1.0];
//    [self.view addSubview:keepOutView];
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
//    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//        [self uiCheckReceipt];
//        [self.tableView nim_scrollToBottom:NO];
//        [self.tableView reloadData];
//
//        [keepOutView removeFromSuperview];
//    });
}

- (void)didRefreshMessageData
{
    [self refreshSessionTitle:self.sessionTitle];
    [self refreshSessionSubTitle:self.sessionSubTitle];
    [self.tableView reloadData];
}

#pragma mark - 会话title
- (NSString *)sessionTitle
{
    NSString *title = @"";
    NIMSessionType type = self.session.sessionType;
    switch (type) {
        case NIMSessionTypeTeam:{
            NIMTeam *team = [[[NIMSDK sharedSDK] teamManager] teamById:self.session.sessionId];
            title = [NSString stringWithFormat:@"%@(%zd)",[team teamName],[team memberNumber]];
        }
            break;
        case NIMSessionTypeP2P:{
            title = [NIMKitUtil showNick:self.session.sessionId inSession:self.session];
        }
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)sessionSubTitle{return @"";};

#pragma mark - NIMChatManagerDelegate

- (void)willSendMessage:(NIMMessage *)message
{
    id<NIMSessionInteractor> interactor = self.interactor;
    
    if ([message.session isEqual:self.session]) {
        if ([interactor findMessageModel:message]) {
            [interactor updateMessage:message];
        }else{
            [interactor addMessages:@[message]];
        }
    }
}

//发送结果
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
}

//发送进度
-(void)sendMessage:(NIMMessage *)message progress:(float)progress
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    NIMMessage *message = messages.firstObject;
    NIMSession *session = message.session;
    if (![session isEqual:self.session] || !messages.count){
        return;
    }
    
    [self uiAddMessages:messages];
    [self sendMessageReceipt:messages];
    
    [self.conversationManager markAllMessagesReadInSession:self.session];
}


- (void)fetchMessageAttachment:(NIMMessage *)message progress:(float)progress
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session]) {
        NIMMessageModel *model = [self.interactor findMessageModel:message];
        //下完缩略图之后，因为比例有变化，重新刷下宽高。
        [model calculateContent:self.tableView.frame.size.width force:YES];
        [self.interactor updateMessage:message];
    }
}

- (void)onRecvMessageReceipt:(NIMMessageReceipt *)receipt
{
    if ([receipt.session isEqual:self.session] && [self shouldHandleReceipt]) {
        [self uiCheckReceipt];
    }
}

/**
 *  会话管理器回调
 */
#pragma mark - NIMConversationManagerDelegate
/**
 *  单个会话里所有消息被删除的回调
 *  @param session 消息所属会话
 */
- (void)messagesDeletedInSession:(NIMSession *)session{
    [self.interactor resetMessages];
    [self.tableView reloadData];
}
/**
 *  增加最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 当新增一条消息，并且本地不存在该消息所属的会话时，会触发此回调。
 */
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}
/**
 *  最近会话修改的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 触发条件包括: 1.当新增一条消息，并且本地存在该消息所属的会话。
 *                          2.所属会话的未读清零。
 *                          3.所属会话的最后一条消息的内容发送变化。(例如成功发送后，修正发送时间为服务器时间)
 *                          4.删除消息，并且删除的消息为当前会话的最后一条消息。
 */
- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}
/**
 *  删除最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 */
- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

//修改最近会话未读消息数
- (void)changeUnreadCount:(NIMRecentSession *)recentSession
         totalUnreadCount:(NSInteger)totalUnreadCount{
    if ([recentSession.session isEqual:self.session]) {
        return;
    }
    [self changeLeftBarBadge:totalUnreadCount];
}

#pragma mark - NIMMediaManagerDelegate
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if (!filePath || error) {
        _sessionInputView.recording = NO;
        [self onRecordFailed:error];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    if(!error) {
        if ([self recordFileCanBeSend:filePath]) {
            [self sendMessage:[NIMMessageMaker msgWithAudio:filePath]];
        }else{
            [self showRecordFileNotSendReason];
        }
    } else {
        [self onRecordFailed:error];
    }
    _sessionInputView.recording = NO;
    
}

- (void)recordAudioDidCancelled {
    _sessionInputView.recording = NO;
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    [_sessionInputView updateAudioRecordTime:currentTime];
}

- (void)recordAudioInterruptionBegin {
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

#pragma mark - 录音相关接口
- (void)onRecordFailed:(NSError *)error{}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    AVURLAsset*audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filepath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);

    if (audioDurationSeconds > 2) {
        return YES;
    }
    return NO;
}

- (void)showRecordFileNotSendReason{}

#pragma mark - NIMInputDelegate
- (void)showInputView
{
    [self.tableView setUserInteractionEnabled:NO];
}

- (void)hideInputView
{
    [self.tableView setUserInteractionEnabled:YES];
}

- (void)inputViewSizeToHeight:(CGFloat)height showInputView:(BOOL)show
{
    [self.tableView setUserInteractionEnabled:!show];
    [self.interactor changeLayout:height];
}

#pragma mark - NIMInputActionDelegate
- (BOOL)onTapMediaItem:(NIMMediaItem *)item{
    SEL sel = item.selctor;
    BOOL handled = sel && [self respondsToSelector:sel];
    if (handled) {
        NIMKit_SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:item]);
        handled = YES;
    }
    return handled;
}

- (void)onTextChanged:(id)sender{}

- (void)onSendText:(NSString *)text atUsers:(NSArray *)atUsers
{
    NSMutableArray *users = [NSMutableArray arrayWithArray:atUsers];
    if (self.session.sessionType == NIMSessionTypeP2P)
    {
        [users addObject:self.session.sessionId];
    }
    NSString *robotsToSend = [self robotsToSend:users];
    
    NIMMessage *message = nil;
    if (robotsToSend.length)
    {
        message = [NIMMessageMaker msgWithRobotQuery:text toRobot:robotsToSend];
    }
    else
    {
        message = [NIMMessageMaker msgWithText:text];
    }
    
    if (atUsers.count)
    {
        NIMMessageApnsMemberOption *apnsOption = [[NIMMessageApnsMemberOption alloc] init];
        apnsOption.userIds = atUsers;
        apnsOption.forcePush = YES;
        
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = self.session;
        
        NSString *me = [[NIMKit sharedKit].provider infoByUser:[NIMSDK sharedSDK].loginManager.currentAccount option:option].showName;
        apnsOption.apnsContent = [NSString stringWithFormat:@"%@在群里@了你",me];
        message.apnsMemberOption = apnsOption;
    }
    [self sendMessage:message];
}

- (NSString *)robotsToSend:(NSArray *)atUsers
{
    for (NSString *userId in atUsers)
    {
        if ([[NIMSDK sharedSDK].robotManager isValidRobot:userId])
        {
            return userId;
        }
    }
    return nil;
}


- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId{}

- (void)onCancelRecording
{
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

- (void)onStopRecording
{
    [[NIMSDK sharedSDK].mediaManager stopRecord];
}

- (void)onStartRecording
{
    _sessionInputView.recording = YES;
    
    NIMAudioType type = NIMAudioTypeAAC;
    if ([self.sessionConfig respondsToSelector:@selector(recordType)])
    {
        type = [self.sessionConfig recordType];
    }
    
    NSTimeInterval duration = [NIMKitUIConfig sharedConfig].globalConfig.recordMaxDuration;
    
    [[NIMSDK sharedSDK].mediaManager addDelegate:self];
    
    [[NIMSDK sharedSDK].mediaManager record:type
                                     duration:duration];
}

#pragma mark - NIMMessageCellDelegate
- (BOOL)onTapCell:(NIMKitEvent *)event{
    BOOL handle = NO;
    NSString *eventName = event.eventName;
    
    
    if ([eventName isEqualToString:NIMKitEventNameTapAudio])
    {
        [self.interactor mediaAudioPressed:event.messageModel];
        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapRobotBlock]) {
        NSDictionary *param = event.data;
        NIMMessage *message = [NIMMessageMaker msgWithRobotSelect:param[@"text"] target:param[@"target"] params:param[@"param"] toRobot:param[@"robotId"]];
        [self sendMessage:message];
        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapRobotContinueSession]) {
        NIMRobotObject *robotObject = (NIMRobotObject *)event.messageModel.message.messageObject;
        NIMRobot *robot = [[NIMSDK sharedSDK].robotManager robotInfo:robotObject.robotId];
        NSString *text = [NSString stringWithFormat:@"%@%@%@",NIMInputAtStartChar,robot.nickname,NIMInputAtEndChar];
        
        NIMInputAtItem *item = [[NIMInputAtItem alloc] init];
        item.uid  = robot.userId;
        item.name = robot.nickname;
        [self.sessionInputView.atCache addAtItem:item];
        
        [self.sessionInputView.toolBar insertText:text];

        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapImage]) {
        [self singleTapSmallViewCallback:event.messageModel.message];
        return YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapVideo]) {
        [self singleTapSmallViewVideoPlayer:event.messageModel.message];
        return YES;
    }

    
    return handle;
}


#pragma mark - 小图单击
- (void)singleTapSmallViewCallback:(NIMMessage *)message
{
    UIApplication *app = [UIApplication sharedApplication];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSData *jsonData = [message.messageObject.description dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"url"]]];
    [imageView sd_setImageWithURL:url];
    [app.keyWindow addSubview:imageView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [button addTarget:self action:@selector(closeShow:) forControlEvents:UIControlEventTouchUpInside];
    [app.keyWindow addSubview:button];
}
//关闭显示
- (void)closeShow:(UIButton *)button
{
    UIApplication *app = [UIApplication sharedApplication];
    UIView *view = [app.keyWindow.subviews objectAtIndex:1];
    [view removeFromSuperview];
    [button removeFromSuperview];
}

#pragma mark -视频播放
- (void)singleTapSmallViewVideoPlayer:(NIMMessage *)message
{
    UIApplication *app = [UIApplication sharedApplication];
    
    UIView *playerView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    playerView.backgroundColor = [UIColor blackColor];
    
    NSData *jsonData = [message.messageObject.description dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"url"]]];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:url]];
    playerLayer.masksToBounds= YES;
    playerLayer.borderColor = [UIColor blackColor].CGColor;
    playerLayer.frame = [[UIScreen mainScreen] bounds];
    
    [playerView.layer addSublayer:playerLayer];
    [app.keyWindow addSubview:playerView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [button addTarget:self action:@selector(closeShow:) forControlEvents:UIControlEventTouchUpInside];
    [app.keyWindow addSubview:button];
    
    [playerLayer.player play];
}
#pragma mark -打开地图
-(void)openMap{
    
}

- (void)onRetryMessage:(NIMMessage *)message
{
    if (message.isReceivedMsg) {
        [[[NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                           error:nil];
    }else{
        [[[NIMSDK sharedSDK] chatManager] resendMessage:message
                                                  error:nil];
    }
}

- (BOOL)onLongPressCell:(NIMMessage *)message
                 inView:(UIView *)view
{
    BOOL handle = NO;
    NSArray *items = [self menusItems:message];
    if ([items count] && [self becomeFirstResponder]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = message;
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
        handle = YES;
    }
    return handle;
}

#pragma mark - 配置项
- (id<NIMSessionConfig>)sessionConfig
{
    return nil;
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    BOOL copyText = NO;
    if (message.messageType == NIMMessageTypeText)
    {
        copyText = YES;
    }
    if (message.messageType == NIMMessageTypeRobot)
    {
        NIMRobotObject *robotObject = (NIMRobotObject *)message.messageObject;
        copyText = !robotObject.isFromRobot;
    }
    if (copyText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyText:)]];
    }
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                action:@selector(deleteMsg:)]];
    return items;
    
}

- (NIMMessage *)messageForMenu
{
    return _messageForMenu;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *items = [[UIMenuController sharedMenuController] menuItems];
    for (UIMenuItem *item in items) {
        if (action == [item action]){
            return YES;
        }
    }
    return NO;
}


- (void)copyText:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    if (message.text.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:message.text];
    }
}

- (void)deleteMsg:(id)sender
{
    NIMMessage *message    = [self messageForMenu];
    [self uiDeleteMessage:message];
    [self.conversationManager deleteMessage:message];
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}


#pragma mark - 操作接口
- (void)uiAddMessages:(NSArray *)messages
{
    [self.interactor addMessages:messages];
}

- (void)uiInsertMessages:(NSArray *)messages
{
    [self.interactor insertMessages:messages];
}

- (NIMMessageModel *)uiDeleteMessage:(NIMMessage *)message{
    NIMMessageModel *model = [self.interactor deleteMessage:message];
    if (model.shouldShowReadLabel)
    {
        [self uiCheckReceipt];
    }
    return model;
}

- (void)uiUpdateMessage:(NIMMessage *)message{
    [self.interactor updateMessage:message];
}

- (void)uiCheckReceipt
{
    if ([self shouldHandleReceipt]) {
        [self.interactor checkReceipt];
    }
}

#pragma mark - NIMMeidaButton
- (void)onTapMediaItemPicture:(NIMMediaItem *)item
{
    [self.interactor mediaPicturePressed];
}

- (void)onTapMediaItemShoot:(NIMMediaItem *)item
{
    [self.interactor mediaShootPressed];
}

- (void)onTapMediaItemLocation:(NIMMediaItem *)item
{
    [self.interactor mediaLocationPressed];
}

#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.lastVisibleIndexPathBeforeRotation = [self.tableView indexPathsForVisibleRows].lastObject;
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.view.window) {
        __weak typeof(self) wself = self;
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
         {
             [[NIMSDK sharedSDK].mediaManager cancelRecord];
             [wself.interactor cleanCache];
             [wself.sessionInputView reset];
             [wself.tableView reloadData];
             [wself.tableView scrollToRowAtIndexPath:wself.lastVisibleIndexPathBeforeRotation atScrollPosition:UITableViewScrollPositionBottom animated:NO];
         } completion:nil];
    }
}


#pragma mark - 标记已读
- (void)markRead
{
    if (![self disableAutoMarkRead]) {
        [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:self.session];
        [self sendMessageReceipt:self.interactor.items];
    }
}

#pragma mark - 已读回执
- (void)sendMessageReceipt:(NSArray *)messages
{
    if ([self shouldHandleReceipt]) {
        [self.interactor sendMessageReceipt:messages];
    }
}


#pragma mark - Private

- (void)addListener
{
    
    if (![self.sessionConfig respondsToSelector:@selector(disableReceiveNewMessages)]
        || ![self.sessionConfig disableReceiveNewMessages]) {
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
    }
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
}

- (void)removeListener
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}

- (void)changeLeftBarBadge:(NSInteger)unreadCount
{
    NIMCustomLeftBarView *leftBarView = (NIMCustomLeftBarView *)self.navigationItem.leftBarButtonItem.customView;
    leftBarView.badgeView.badgeValue = @(unreadCount).stringValue;
    leftBarView.badgeView.hidden = !unreadCount;
}


- (BOOL)shouldHandleReceipt
{
    return [self.interactor shouldHandleReceipt];
}


- (BOOL)disableAutoMarkRead
{
    return [self.sessionConfig respondsToSelector:@selector(disableAutoMarkMessageRead)] &&
    [self.sessionConfig disableAutoMarkMessageRead];
}

- (id<NIMConversationManager>)conversationManager{
    switch (self.session.sessionType) {
        case NIMSessionTypeChatroom:
            return nil;
            break;
        case NIMSessionTypeP2P:
        case NIMSessionTypeTeam:
        default:
            return [NIMSDK sharedSDK].conversationManager;
    }
}


- (void)setUpTitleView
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    self.titleLabel.text = self.sessionTitle;
 
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.subTitleLabel  = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subTitleLabel.textColor = [UIColor grayColor];
    self.subTitleLabel.font = [UIFont systemFontOfSize:12.f];
    self.subTitleLabel.text = self.sessionSubTitle;
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *titleView = [[UIView alloc] init];
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:self.subTitleLabel];
    
    self.navigationItem.titleView = titleView;
    
    [self layoutTitleView];
    
}

- (void)layoutTitleView
{
    CGFloat maxLabelWidth = 150.f;
    [self.titleLabel sizeToFit];
    self.titleLabel.nim_width = maxLabelWidth;
    
    [self.subTitleLabel sizeToFit];
    self.subTitleLabel.nim_width = maxLabelWidth;
    
    
    UIView *titleView = self.navigationItem.titleView;
    
    titleView.nim_width  = MAX(self.titleLabel.nim_width, self.subTitleLabel.nim_width);
    titleView.nim_height = self.titleLabel.nim_height + self.subTitleLabel.nim_height;
    
    self.subTitleLabel.nim_bottom  = titleView.nim_height;
}



- (void)refreshSessionTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self layoutTitleView];
}


- (void)refreshSessionSubTitle:(NSString *)title
{
    self.subTitleLabel.text = title;
    [self layoutTitleView];
}


@end

