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

@interface CircleViewController ()<UITableViewDelegate,UITableViewDataSource,AVPlayerViewControllerDelegate>{
    
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
    
    if ([self.content isEqualToString:@"新闻事实"]) {
        [self newsBtnAction:nil];
    }else if([self.content isEqualToString:@"创业"]){
        [self aidBtnAction:nil];
    }else if ([self.content isEqualToString:@"求助"]){
        [self seekHelpBtnAction:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tianjia@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addMoment)];
    
    if (_content.length>0) {
        self.title = _content;
    }else{
        [self initUI];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
}
- (void)initUIForUserInfo{
    
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
        paramDic = @{@"type":moduleType,@"page":@"1",@"uid":[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"]]};
    }else{
        paramDic = @{@"type":moduleType,@"page":@"1"};
    }
    NSLog(@"%@",paramDic);
    [DataService requestWithPostUrl:@"/api/list/getItemList" params:paramDic block:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            [self initMoment:[[result objectForKey:@"data"]objectForKey:@"list"]];
        }
    }];
}

#pragma mark - 测试数据
- (void)initMoment:(NSMutableArray*)resultArray
{
    self.momentArray = [NSMutableArray arrayWithCapacity:0];
    self.dataArray = [NSMutableArray arrayWithArray:resultArray];
    
    if (!self.dataArray.count) {
        [self addQueshengImageToView:self.view imageName:@"dongtai@2x.png" hidden:NO];
        return;
    }else{
        [self addQueshengImageToView:self.view imageName:@"dongtai@2x.png" hidden:YES];
        for (NSDictionary * dic in resultArray) {
            
            Moment *moment = [[Moment alloc] init];
            moment.userName = [dic objectForKey:@"username"];
            moment.userThumbPath = [dic objectForKey:@"head_url"];
            moment.time = [[dic objectForKey:@"add_time"] longLongValue];
            moment.singleWidth = 500;
            moment.singleHeight = 315;
            NSMutableArray * array = [NSMutableArray arrayWithArray:[dic objectForKey:@"path"]];
            moment.fileCount = array.count;
            moment.imageArray = array;
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
    published.moduleType = moduleType;
    [self.navigationController pushViewController:published animated:YES];
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
    static NSString *identifier = @"MomentCell";
    MomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    if ([moduleType isEqualToString:@"3"]) {
        cell.commentNum = -1;
    }else{
        cell.commentNum = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"comment_num"] intValue];
    }
    
    cell.moment = [self.momentArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = [NSString stringWithFormat:@"测试%ld",(long)indexPath.row];
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
    // 使用缓存行高，避免计算多次
    Moment *moment = [self.momentArray objectAtIndex:indexPath.row];
    return moment.rowHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([moduleType isEqualToString:@"3"]) {
        SeekHelpDetailsViewController *seekDetails = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil ]instantiateViewControllerWithIdentifier:@"seekDetails"];
        
        seekDetails.commentId = [[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
        [self.navigationController pushViewController:seekDetails animated:YES];
    }else{
        DetailsViewController * details = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"details"];
        details.commentId = [[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
        [self.navigationController pushViewController:details animated:YES];
    }
    
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath =  [self.tableView indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
    MomentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.menuView.show = NO;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
