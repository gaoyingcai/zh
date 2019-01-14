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
#import "MyButton.h"
#import "WXApi.h"
#import "MJRefreshAutoNormalFooter.h"


@interface DetailsViewController ()<MomentCellDelegate>{
    UIView *backView;
    UIView * textFieldView;
    UITextField * textField;
    NSMutableArray *dataArray;
    NSString * pinglunContent;
    NSMutableArray *helpDataArray;
    MyButton *payButton;
    NSString * suid;
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
    if (_isSeekHelp) {
        [self loadHelpData];
//        helpDataArray =[NSMutableArray arrayWithObject:@""];
//        self.tableView.mj_footer= [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            [self loadHelpData];
//        }];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    [self initPayButton];
}
-(void)initPayButton{
    
    payButton = [MyButton buttonWithType:UIButtonTypeCustom];
    payButton.backgroundColor = color_green;
    payButton.frame = CGRectMake(0, self.view.frame.size.height-90, self.view.frame.size.width, 90);
    [payButton setImage:[UIImage imageNamed:@"aixin.png"] forState:UIControlStateNormal];
    [payButton setTitle:@" 购买" forState:UIControlStateNormal];
    payButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [payButton addTarget:self action:@selector(helpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    payButton.hidden = YES;
    [self.view addSubview:payButton];
    
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
-(void)loadHelpData{
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"ORDER_PAY_NOTIFICATION_HELP"];
    
    NSDictionary * paramDic = @{@"id":[NSString stringWithFormat:@"%d",_commentId]};
    [DataService requestWithPostUrl:@"api/list/getItem" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self initViewWith:[[result objectForKey:@"data"] objectAtIndex:0]];
        }
    }];
}
-(void)initViewWith:(NSMutableDictionary*)dataDic{
    NSArray *dataArray = [dataDic objectForKey:@"comments"];
//    if (dataArray.count<5) {
//        [self.tableView.mj_footer endRefreshingWithNoMoreData];
//    }
    helpDataArray =[NSMutableArray arrayWithObject:@""];
    [helpDataArray addObjectsFromArray:dataArray];
    [self.tableView reloadData];
}
#pragma mark - 处理数据
- (void)initTestInfo:(NSArray *)data
{
    dataArray = [NSMutableArray arrayWithArray:data];
    for (NSDictionary *momentDic in data) {
        
        NSString * uid = [[self getUserinfo] objectForKey:@"uid"] ;
        suid = [momentDic objectForKey:@"uid"];
        if ([uid isEqualToString:suid]||!_isSeekHelp) {
            payButton.hidden = YES;
            self.tableViewBottom.constant  =0;
        }else{
            payButton.hidden =NO;
        }
        
        self.momentList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *commentList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *commentResultList = [NSMutableArray arrayWithArray:[momentDic objectForKey:@"comments"]];
        // 评论
        if (!_isSeekHelp) {
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
                [commentList addObject:comment];
            }
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
    
    if (_isSeekHelp) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:0];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
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
//    return [self.momentList count];
    if (helpDataArray.count) {
        if (helpDataArray.count>1) {
            return helpDataArray.count+1;
        }
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *identifier = @"MomentCell";
//        MomentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (cell == nil) {
            MomentCell *cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
//        }
        [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
//        if (!cell.hidden) {
            if (_myDynamic) {
                NSLog(@"%@",cell);
                cell.pinglunView = NO;
            }else{
                cell.pinglunView = YES;
            }
            cell.commentNum = -1;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.moment = [self.momentList objectAtIndex:indexPath.row];
            cell.delegate = self;
//        }
        return cell;
    }else if (indexPath.row == 1) {
        static NSString *seekIdentifier = @"seekCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:seekIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:seekIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
        label.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:label];
        
        UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, k_view_width(cell), 30)];
        textLabel.text = @"爱心流水";
        [cell.contentView addSubview:textLabel];
        return cell;
    }
    static NSString *identifier = @"MomentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, tableView.frame.size.width/2, 30)];
    NSLog(@"%lu",(unsigned long)helpDataArray.count);
    NSLog(@"%ld",(long)indexPath.row);
    NSLog(@"***********");
    nameLabel.text =[NSString stringWithFormat:@"%@",[[helpDataArray objectAtIndex:indexPath.row-1]objectForKey:@"username"]];
    nameLabel.textColor = [UIColor darkGrayColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:nameLabel];
    
    UILabel * moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width/2, 0, tableView.frame.size.width/2-8, 30)];
    moneyLabel.textAlignment= NSTextAlignmentRight;
    moneyLabel.text =[NSString stringWithFormat:@"捐出%@元",[[helpDataArray objectAtIndex:indexPath.row-1]objectForKey:@"money"]];
    moneyLabel.textColor = [UIColor darkGrayColor];
    moneyLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:moneyLabel];
    
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // 使用缓存行高，避免计算多次
        Moment *moment = [self.momentList objectAtIndex:indexPath.row];
        return moment.rowHeight;
    }else if(indexPath .row == 1){
        return 30;
    }
    return 40;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath =  [self.tableView indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
    NSLog(@"%@",indexPath);
    NSLog(@"%ld",(long)indexPath.section);
    NSLog(@"%ld",(long)indexPath.row);
    MomentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.menuView.show = NO;

    
}

#pragma mark - 资助
- (IBAction)helpBtnAction:(id)sender {
    NSDictionary * paramDic = @{@"field":@"sup_money"};
    [DataService requestWithPostUrl:@"api/config/getConfig" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self alert:[[result objectForKey:@"data"] objectForKey:@"money"]];
        }
    }];
}
-(void)alert:(NSString*)money{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否捐助一颗爱心给他" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pay:money];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)pay:(NSString*)payMoney{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHelpData) name:@"ORDER_PAY_NOTIFICATION_HELP" object:nil];
    
    NSDictionary *paramDic = @{@"uid":[[self getUserinfo] objectForKey:@"uid"],
                               @"money":payMoney,
                               @"suid":suid,
                               @"info_id":[NSString stringWithFormat:@"%d",_commentId],
                               @"type":@"2",
                               };
    
    [DataService requestWithPostUrl:@"/api/payment/payOrder" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            [self setOrderString:[result objectForKey:@"data"]];
        }
    }];
}
-(void)setOrderString:(NSDictionary*)dic{
    
    if ([dic objectForKey:@"partnerid"]) {
        PayReq *request = [[PayReq alloc] init];
        request.partnerId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"partnerid"]];
        request.prepayId= [NSString stringWithFormat:@"%@",[dic objectForKey:@"prepayid"]];
        request.package = @"Sign=WXPay";
        request.nonceStr= [NSString stringWithFormat:@"%@",[dic objectForKey:@"noncestr"]];
        request.timeStamp= [[dic objectForKey:@"timestamp"] intValue];
        request.sign= [NSString stringWithFormat:@"%@",[dic objectForKey:@"sign"]];
        [WXApi sendReq:request];
    }
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
