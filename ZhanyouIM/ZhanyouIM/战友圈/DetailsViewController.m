//
//  Details ViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/29.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "DetailsViewController.h"
#import "MomentCell.h"
#import "Moment.h"
#import "Comment.h"
#import "DataService.h"
#import "UserInfoViewController.h"


@interface DetailsViewController ()<MomentCellDelegate>{
    UIView *backView;
    UIView * textFieldView;
    UITextField * textField;
    NSMutableArray *dataArray;
    NSString * pinglunContent;
}

@property (nonatomic, strong) NSMutableArray *momentList;
@end

@implementation DetailsViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self initTestInfo];
    [self loadDetailsData];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
}

-(void)loadDetailsData{
    
    NSDictionary * paramDic = @{@"id":[NSString stringWithFormat:@"%d",_commentId]};
    [DataService requestWithPostUrl:@"api/list/getItem" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self initTestInfo:[result objectForKey:@"data"]];
        }
    }];
}
#pragma mark - 处理数据
- (void)initTestInfo:(NSArray *)data
{
    dataArray = [NSMutableArray arrayWithArray:data];
    for (NSDictionary *momentDic in data) {
        
        self.momentList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *commentList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *commentResultList = [NSMutableArray arrayWithArray:[momentDic objectForKey:@"comments"]];
        // 评论
        for (int i = 0; i < commentResultList.count; i ++) {
            Comment *comment = [[Comment alloc] init];
            comment.userName = [NSString stringWithFormat:@"%@",[[commentResultList objectAtIndex:i] objectForKey:@"username"]];
            comment.userImage = [[commentResultList objectAtIndex:i] objectForKey:@"head_url"];
            comment.text = [[commentResultList objectAtIndex:i] objectForKey:@"content"];
            comment.userPhone =[[commentResultList objectAtIndex:i] objectForKey:@"phone"];
            NSString * addTime = [[commentResultList objectAtIndex:i] objectForKey:@"add_time"];
            if (![addTime isKindOfClass:[NSNull class]]&&![addTime isEqualToString:@"<null>"]){
                comment.time = [addTime longLongValue];
            }
//        if (j % 2 == 0) {
//            comment.pk = 3;
//            comment.replyUserName = @"曾小贤";
//        }
            [commentList addObject:comment];
        }
        
        Moment *moment = [[Moment alloc] init];
        moment.userName = [NSString stringWithFormat:@"%@",[momentDic objectForKey:@"username"]];
        moment.userThumbPath = [momentDic objectForKey:@"head_url"];
        moment.time = [[momentDic objectForKey:@"add_time"] longLongValue];
        moment.singleWidth = 500;
        moment.singleHeight = 315;
        NSMutableArray * array = [NSMutableArray arrayWithArray:[momentDic objectForKey:@"path"]];
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
        moment.text = [momentDic objectForKey:@"content"];
        moment.commentList = commentList;
        NSString *locationStr = [momentDic objectForKey:@"location"];
        if (![locationStr isKindOfClass:[NSNull class]]&&![locationStr isEqualToString:@"<null>"]) {
            moment.location = locationStr;
        }
        [self.momentList addObject:moment];
    }
    [self.tableView reloadData];
    
}


#pragma mark - 发布动态
- (void)addMoment
{
    NSLog(@"新增");
}
-(void)getFriendInfo:(NSString *)phone{
    UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
    userInfo.phone = phone;
    userInfo.rightBtn = YES;
    userInfo.postMessage = YES;
    [self.navigationController pushViewController:userInfo animated:YES];
}
#pragma mark - MomentCellDelegate
// 点击用户头像
- (void)didClickProfile:(MomentCell *)cell
{
    NSLog(@"击用户头像");
    
    NSDictionary *dic = [self->dataArray objectAtIndex:cell.tag];
    [self getFriendInfo:[dic objectForKey:@"accid"]];
    
    
}

// 点赞
- (void)didLikeMoment:(MomentCell *)cell
{
    NSLog(@"点赞");
}
#pragma mark --键盘的显示隐藏--
-(void)keyboardWillShow:(NSNotification *)notification{

    CGFloat curkeyBoardHeight = [[[notification userInfo]objectForKey:@"UIKeyboardBoundsUserInfoKey"]CGRectValue].size.height;
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"]CGRectValue];
    CGRect end = [[[notification userInfo]objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    if (begin.size.height>0 && begin.origin.y-end.origin.y>0) {
        [UIView animateWithDuration:0.3 animations:^{
            self->textFieldView.frame = CGRectMake(0, k_screen_height-curkeyBoardHeight - 44, k_screen_width, 44);
        }];
        
    }

}
-(void)keyboardWillHide:(NSNotification *)notification{
//    [self pinglunBtnAction];
    [textFieldView removeFromSuperview];
    textFieldView = nil;
}
// 评论
- (void)didAddComment:(MomentCell *)cell
{
    NSLog(@"评论");
    if (backView == nil) {
        backView = [[UIView alloc]initWithFrame:self.view.frame];
        backView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:backView];
    }
    
    
    textFieldView = [[UIView alloc]initWithFrame:CGRectMake(0, k_screen_height, k_screen_width, 45)];
    textFieldView.backgroundColor = color_lightGray;
    [self.view addSubview:textFieldView];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, k_screen_width, 1)];
    label.backgroundColor = [UIColor blackColor];
    [textFieldView addSubview:label];
    
    textField= [[UITextField alloc]initWithFrame:CGRectMake(16, 5, k_screen_width-70, 34)];
    [textField becomeFirstResponder];
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"评论";
    textField.layer.cornerRadius = 3.0;
    textField.layer.masksToBounds = YES;
    [textFieldView addSubview:textField];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(k_screen_width-50, 5, 44, 34);
    [button setTitle:@"评论" forState:UIControlStateNormal];
    [button setTitleColor:color_green forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pinglunBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [textFieldView addSubview:button];
    

}
-(void)pinglunBtnAction{
    
    if (textField.text.length==0) {
        [self->textField resignFirstResponder];
        return;
    }

    NSDictionary * paramDic= @{@"uid":[[self getUserinfo] objectForKey:@"uid"],@"info_id":[NSString stringWithFormat:@"%d",_commentId],@"content":textField.text};
    [DataService requestWithPostUrl:@"/api/trend/comment" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self->textField resignFirstResponder];
            [self loadDetailsData];
        }
    }];
    
}

// 查看全文/收起
- (void)didSelectFullText:(MomentCell *)cell
{
    NSLog(@"全文/收起");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

// 删除
- (void)didDeleteMoment:(MomentCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 取消
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 删除
        [self.momentList removeObject:cell.moment];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"删除");
}

// 选择评论
- (void)didSelectComment:(Comment *)comment
{
    NSLog(@"点击评论");
    [self getFriendInfo:comment.userPhone];
}

// 点击高亮文字
- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText
{
    NSLog(@"点击高亮文字：%@",linkText);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.momentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MomentCell";
    MomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if (_myDynamic) {
        cell.pinglunView = NO;
    }else{
        cell.pinglunView = YES;
    }
    cell.commentNum = -1;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.moment = [self.momentList objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 使用缓存行高，避免计算多次
    Moment *moment = [self.momentList objectAtIndex:indexPath.row];
    return moment.rowHeight;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath =  [self.tableView indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
    MomentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.menuView.show = NO;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [textField resignFirstResponder];
    [backView removeFromSuperview];
    backView = nil;
    
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
