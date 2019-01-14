//
//  CircleViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/11.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.

#import "CircleViewController.h"
#import "DetailsViewController.h"
#import "MomentCell.h"
#import "Moment.h"
#import "Comment.h"
#import "DataService.h"
#import "PublishedViewController.h"
#import "SeekHelpDetailsViewController.h"
#import <AVKit/AVKit.h>
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshNormalHeader.h"
#import "UserInfoViewController.h"

@interface CircleViewController ()<UITableViewDelegate,UITableViewDataSource,AVPlayerViewControllerDelegate,MomentCellDelegate>{
    
    UIButton *newsBtn;
    UIButton *aidBtn;
    UIButton *seekHelpBtn;
    
}

@property (nonatomic, strong) NSMutableArray *momentArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
//@property (nonatomic, strong) UIView *tableHeaderView;

@end

@implementation CircleViewController

static NSString *moduleType;

-(void)viewWillAppear:(BOOL)animated{
    if (self.myDynamic) {
        self.tabBarController.tabBar.hidden = YES;
    }else{
        self.tabBarController.tabBar.hidden = NO;
    }
}

//-(void)viewWillDisappear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = NO;
//    if (self.myDynamic) {
//        self.tabBarController.tabBar.hidden = YES;
//    }else{
//        self.tabBarController.tabBar.hidden = NO;
//    }
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.momentArray = [NSMutableArray arrayWithCapacity:0];
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    if (!_myDynamic) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tianjia@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addMoment)];
    }
    
    if ([self.content isEqualToString:@"新闻事实"]) {
        [self newsBtnAction:nil];
    }else if([self.content isEqualToString:@"创业"]){
        [self aidBtnAction:nil];
    }else if ([self.content isEqualToString:@"求助"]){
        [self seekHelpBtnAction:nil];
    }else{
        [self newsBtnAction:nil];
    }
    
    if (_content.length>0) {
        self.title = _content;
    }else{
        [self initUI];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.momentArray removeAllObjects];
        [self loadData];
    }];
    self.tableView.mj_footer= [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadData];
    }];
    
//    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//         [self loadData];
//    }];
    // 在快划到底部44px的时候就会自动刷新
//    footer.triggerAutomaticallyRefreshPercent = -3;
//    self.tableView.mj_footer = footer;
    
}


#pragma mark - 构建UI
- (void)initUI{
    UIView * titleView = [[UIView alloc]initWithFrame:CGRectMake(k_screen_width/5, 5, k_screen_width*3/5, 30)];
    titleView.backgroundColor = color_green;
    titleView.layer.cornerRadius = 4;
    titleView.layer.masksToBounds = YES;
    titleView.layer.borderWidth = 1;
    titleView.layer.borderColor = color_green.CGColor;
    self.navigationItem.titleView = titleView;
    
    moduleType = @"1";
    
    newsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newsBtn.frame = CGRectMake(0, 0, k_view_width(titleView)/3-1, k_view_height(titleView));
    [newsBtn setTitle:@"新闻事实" forState:UIControlStateNormal];
    newsBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [newsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newsBtn.backgroundColor = color_green;
    [newsBtn addTarget:self action:@selector(newsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:newsBtn];
    
    aidBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aidBtn.frame = CGRectMake(k_view_width(titleView)/3, 0, k_view_width(titleView)/3, k_view_height(titleView));
    [aidBtn setTitle:@"创业" forState:UIControlStateNormal];
    aidBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [aidBtn setTitleColor:color_green forState:UIControlStateNormal];
    aidBtn.backgroundColor = [UIColor whiteColor];
    [aidBtn addTarget:self action:@selector(aidBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:aidBtn];
    
    seekHelpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    seekHelpBtn.frame = CGRectMake(k_view_width(titleView)*2/3+1, 0, k_view_width(titleView)/3-1, k_view_height(titleView));
    [seekHelpBtn setTitle:@"求助" forState:UIControlStateNormal];
    seekHelpBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [seekHelpBtn setTitleColor:color_green forState:UIControlStateNormal];
    seekHelpBtn.backgroundColor = [UIColor whiteColor];
    [seekHelpBtn addTarget:self action:@selector(seekHelpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:seekHelpBtn];
    
    if ([_content isEqualToString:@"创业"]) {
        [self aidBtnAction:nil];
    }else if([_content isEqualToString:@"求助"]){
        [self seekHelpBtnAction:nil];
    }
}
-(void)newsBtnAction:(UIButton*)btn{
    self.momentArray = [NSMutableArray arrayWithCapacity:0];
    self.dataArray = [NSMutableArray arrayWithCapacity:0];

    moduleType = @"1";
    [newsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newsBtn.backgroundColor = color_green;
    
    [aidBtn setTitleColor:color_green forState:UIControlStateNormal];
    aidBtn.backgroundColor = [UIColor whiteColor];
    
    [seekHelpBtn setTitleColor:color_green forState:UIControlStateNormal];
    seekHelpBtn.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
}
-(void)aidBtnAction:(UIButton*)btn{
    self.momentArray = [NSMutableArray arrayWithCapacity:0];
    self.dataArray = [NSMutableArray arrayWithCapacity:0];

    moduleType = @"2";
    [newsBtn setTitleColor:color_green forState:UIControlStateNormal];
    newsBtn.backgroundColor = [UIColor whiteColor];
    
    [aidBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aidBtn.backgroundColor = color_green;;
    
    [seekHelpBtn setTitleColor:color_green forState:UIControlStateNormal];
    seekHelpBtn.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
}
-(void)seekHelpBtnAction:(UIButton*)btn{
    self.momentArray = [NSMutableArray arrayWithCapacity:0];
    self.dataArray = [NSMutableArray arrayWithCapacity:0];

    moduleType = @"3";
    [newsBtn setTitleColor:color_green forState:UIControlStateNormal];
    newsBtn.backgroundColor = [UIColor whiteColor];
    
    [aidBtn setTitleColor:color_green forState:UIControlStateNormal];
    aidBtn.backgroundColor = [UIColor whiteColor];
    
    [seekHelpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    seekHelpBtn.backgroundColor = color_green;
    
    [self loadData];
}

-(void)loadData{
    
    NSDictionary *paramDic;
    if (self.myDynamic) {
        paramDic = @{@"type":moduleType,@"page":[NSString stringWithFormat:@"%lu",self.momentArray.count/5+1],@"uid":[NSString stringWithFormat:@"%@",[[self getUserinfo] objectForKey:@"uid"]]};
    }else{
        paramDic = @{@"type":moduleType,@"page":[NSString stringWithFormat:@"%lu",self.momentArray.count/5+1]};
    }
    NSLog(@"%@",paramDic);
    [DataService requestWithPostUrl:@"/api/list/getItemList" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            NSLog(@"%@",result);
            [self initMoment:[[result objectForKey:@"data"]objectForKey:@"list"]];
        }
    }];
}

#pragma mark - 测试数据
- (void)initMoment:(NSMutableArray*)resultArray
{
    
    if (resultArray.count<5) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    [self.dataArray addObjectsFromArray:resultArray];
    
    
    if (!self.dataArray.count) {
        [self addQueshengImageToView:self.view imageName:@"dongtai@2x.png" hidden:NO];
//        self.tableView.mj_footer = nil;
        self.tableView.mj_footer.hidden =YES;
    }else{
        self.tableView.mj_footer.hidden =NO;
        [self addQueshengImageToView:self.view imageName:@"dongtai@2x.png" hidden:YES];
        for (NSDictionary * dic in resultArray) {
            
            Moment *moment = [[Moment alloc] init];
            moment.userName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
            moment.userThumbPath = [dic objectForKey:@"head_url"];
            moment.time = [[dic objectForKey:@"add_time"] longLongValue];
            moment.singleWidth = 500;
            moment.singleHeight = 315;
            NSMutableArray * array = [NSMutableArray arrayWithArray:[dic objectForKey:@"path"]];
            if (array.count == 2) {
                NSMutableDictionary *dic1 = [array objectAtIndex:0];
                NSMutableDictionary *dic2 = [array objectAtIndex:1];
                if ([[dic1 allKeys] containsObject:@"path_source"]) {
                    moment.fileCount = 1;
                    [dic1 setValuesForKeysWithDictionary:dic2];
                    moment.imageArray = [NSMutableArray arrayWithObject:dic1];
                }else if ([[dic2 allKeys] containsObject:@"path_source"]){
                    moment.fileCount = 1;
                    [dic2 setValuesForKeysWithDictionary:dic1];
                    moment.imageArray = [NSMutableArray arrayWithObject:dic2];
                }else{
                    moment.fileCount = 2;
                    moment.imageArray = array;
                }
            }else{
                moment.fileCount = array.count;
                moment.imageArray = array;
            }
            moment.text = [dic objectForKey:@"content"];
            NSString *locationStr = [dic objectForKey:@"location"];
            if (![locationStr isKindOfClass:[NSNull class]]) {
                moment.location = locationStr;
            }
            [self.momentArray addObject:moment];
        }
    }
    [_tableView reloadData];

}

#pragma mark *** AVPlayerViewControllerDelegate ***
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"1 2 3456");
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"12 3 456");
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"123 4 56");
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"1234 5 6");
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"12345 6");
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


#pragma mark - 发布动态
- (void)addMoment
{
    NSLog(@"新增");
    PublishedViewController *published = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"published"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reload:) name:@"QZ" object:nil];
    published.moduleType = moduleType;
    [self.navigationController pushViewController:published animated:YES];
}
-(void)reload:(NSNotification*)sender{
    NSLog(@"%@",sender.userInfo);
    //注意关闭通知，否则下次监听还会收到这次的通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSString *str = [sender.userInfo objectForKey:@"type"];
    
    switch ([str intValue]) {
        case 1:
            [self newsBtnAction:nil];
            break;
        case 2:
            [self aidBtnAction:nil];
            break;
        case 3:
            [self seekHelpBtnAction:nil];
            break;
        default:
            break;
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.momentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *identifier = @"MomentCell";
//    MomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor whiteColor];
//    }
    
    
//    static NSString *identifier = @"MomentCell";
//    MomentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
//    if (cell == nil) {
//        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor whiteColor];
//    }
    
//    MomentCell *cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    
    

    MomentCell *cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];

    
    if ([moduleType isEqualToString:@"3"]) {
        cell.commentNum = -1;
    }else{
        if (self.dataArray.count) {
            cell.commentNum = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"comment_num"] intValue];
        }
    }
    NSLog(@"momentArray ==%@",self.momentArray);
    if (self.momentArray.count) {
        cell.moment = [self.momentArray objectAtIndex:indexPath.row];
    }
//    cell.textLabel.text = [NSString stringWithFormat:@"测试%ld",(long)indexPath.row];
    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
    
    
    
//    MomentCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.backgroundColor = [UIColor whiteColor];
//    cell.commentNum = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"comment_num"] intValue];
//    cell.moment = [self.momentArray objectAtIndex:indexPath.row];
//    return cell;

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 使用缓存行高，避免计算多
    if (self.momentArray.count) {
        Moment *moment = [self.momentArray objectAtIndex:indexPath.row];
        return moment.rowHeight;
    }
    return 1;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if ([moduleType isEqualToString:@"3"]) {
//        SeekHelpDetailsViewController *seekDetails = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil ]instantiateViewControllerWithIdentifier:@"seekDetails"];
//
//        seekDetails.commentId = [[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
//        [self.navigationController pushViewController:seekDetails animated:YES];
//    }else{
        DetailsViewController * details = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"details"];
    if ([moduleType isEqualToString:@"3"]) {
        details.myDynamic = YES;
        details.isSeekHelp = YES;
    }else{
        details.isSeekHelp = NO;
        details.myDynamic = self.myDynamic;
    }
    
        details.commentId = [[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
        [self.navigationController pushViewController:details animated:YES];
//    }
    
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath =  [self.tableView indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
    MomentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.menuView.show = NO;
}

-(void)getFriendInfo:(NSString *)phone{
    UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
    userInfo.phone = phone;
    userInfo.rightBtn = YES;
    userInfo.postMessage = YES;
    [self.navigationController pushViewController:userInfo animated:YES];
}

#pragma mark - MomentCellDelegate
- (void)didClickProfile:(MomentCell *)cell
{
    NSLog(@"击用户头像");
    
    NSDictionary *dic = [self.dataArray objectAtIndex:cell.tag];
    [self getFriendInfo:[dic objectForKey:@"accid"]];
    
    
    
//    cell.moment.userId
}
- (void)didSelectFullText:(MomentCell *)cell
{
    NSLog(@"全文/收起");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
