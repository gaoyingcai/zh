//
//  NewGroupViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "NewGroupViewController.h"
#import "HomeCell.h"
#import "pinyin.h"
#import <NIMSDK/NIMSDK.h>
#import "UIImageView+WebCache.h"
#import "DataService.h"
#import "NIMSessionViewController.h"

@interface NewGroupViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *initialArray;//首字母数组
    NSArray *firendArray;//获取到的好友信息l数组
    NSMutableArray *dataArray;//用来展示tableView的数组
    
}
@property (nonatomic,strong)NSMutableArray *selectorPatnArray;//存放选中数据
@property (nonatomic,strong)NSMutableArray *selectorIdArray;//存放选中数据

@end

@implementation NewGroupViewController

#pragma mark -懒加载

- (NSMutableArray *)selectorPatnArray{
    if (!_selectorPatnArray) {
        _selectorPatnArray = [NSMutableArray array];
    }
    return _selectorPatnArray;
}
- (NSMutableArray *)selectorIdArray{
    if (!_selectorIdArray) {
        _selectorIdArray = [NSMutableArray array];
    }
    return _selectorIdArray;
}
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [cell setSelected:YES animated:YES];
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 25, 25);
    [btn setTitleColor:color_green forState:UIControlStateNormal];
    
    if (_teamUserIdArray.count) {
        [btn setTitle:@"添加" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addBtnaAddAction:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn setTitle:@"创建" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addBtnCreateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
    
    firendArray = [NSMutableArray arrayWithArray:[NIMSDK sharedSDK].userManager.myFriends];
    NSLog(@"%@",firendArray);
    
    
    initialArray=[[NSMutableArray alloc] init];
    dataArray = [NSMutableArray arrayWithCapacity:0];

    for (int i=0; i<[firendArray count]; i++) {

        NIMUser *user = [firendArray objectAtIndex:i];
        NSString* personname=user.userInfo.nickName;
        char first=pinyinFirstLetter([personname characterAtIndex:0]);
        NSLog(@"%c",first);
        NSString *sectionName;
        if ((first>='a'&&first<='z')||(first>='A'&&first<='Z')) {
                sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([personname characterAtIndex:0])] uppercaseString];
        }else {
            sectionName=[[NSString stringWithFormat:@"%c",'#'] uppercaseString];
        }
        if ([initialArray containsObject:sectionName]) {
            NSMutableArray * array= [dataArray objectAtIndex:[initialArray indexOfObject:sectionName]];
            [array addObject:[firendArray objectAtIndex:i]];
        }else{
            [initialArray addObject:sectionName];
            NSMutableArray *array = [NSMutableArray arrayWithObject:[firendArray objectAtIndex:i]];
            [dataArray addObject:array];
        }
    }
    
    [self.tableView setEditing:YES animated:YES];
}

-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
    NSComparisonResult result = [contactName compare:searchT options:NSCaseInsensitiveSearch
                                               range:NSMakeRange(0, searchT.length)];
    if (result == NSOrderedSame)
        return YES;
    else
        return NO;
}
-(void)addBtnaAddAction:(UIButton*)btn{
    [[NIMSDK sharedSDK].teamManager addUsers:_selectorIdArray toTeam:_teamId postscript:@"" completion:^(NSError * _Nullable error, NSArray<NIMTeamMember *> * _Nullable members) {
        NSLog(@"error :%@",error);
        if (!error) {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -3)] animated:YES];
        }
    }];
}
-(void)addBtnCreateAction:(UIButton*)btn{
    NSLog(@"新建群聊");
    
    NSString * nameStr;
//    //凭借图片
//    //开启图形上下文
//    UIGraphicsBeginImageContext(CGSizeMake(308,308));
    if (_selectorIdArray.count>1) {
        for (int i = 0; i<_selectorPatnArray.count; i++) {
//            //群聊名称
            NIMUser * user = [_selectorPatnArray objectAtIndex:i];
            if (nameStr.length>0) {
                nameStr = [NSString stringWithFormat:@"%@、%@",nameStr,user.userInfo.nickName];
            }else{
                nameStr = user.userInfo.nickName;
            }
//            //群聊图片
//            //1.获取url地址
//            NSURL*url = [NSURL URLWithString:domain_img(user.userInfo.avatarUrl)];
//            //2.下载图片
//            NSData*data = [NSData dataWithContentsOfURL:url];
//            //3.把二进制数据转换成图片
//            UIImage *image = [UIImage imageWithData:data];
//            //画1
//            [image drawInRect:CGRectMake(110*i+10,i/3*110+10,100,100)];
//            //画2[self.image2drawInRect:CGRectMake(0,100,200,100)];
        }
//        //根据图形上下文拿到图片
//        UIImage*image =UIGraphicsGetImageFromCurrentImageContext();
//        //关闭上下文
//        UIGraphicsEndImageContext();
//        NSArray *imageArray = @[image];
    
//    if (_selectorIdArray.count>1) {
        UIImage * image = [UIImage imageNamed:@"qunzu@2x.png"];
        NSArray *imageArray = @[image];
        NSDictionary * paramDic = @{@"imageArray":imageArray,@"fileName":@"card.jpg"};
        [DataService requestWithUploadImageUrl:@"/api/upload/upload" params:paramDic block:^(id result) {
            if (result) {
                NSLog(@"result");
                [self pushNewTeamWithName:nameStr imageUrl:[NSString stringWithFormat:@"%@",[[result objectForKey:@"data"] objectAtIndex:0]]];
            }
        }];
    }else{
        [self showTextMessage:@"至少选择两名好友"];
    }
}

-(void)pushNewTeamWithName:(NSString* )name imageUrl:(NSString*)imageUrl{
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc]init];
    option.name = name;
    option.avatarUrl = imageUrl;
    [[NIMSDK sharedSDK].teamManager createTeam:option users:_selectorIdArray completion:^(NSError * _Nullable error, NSString * _Nullable teamId) {
        if (error) {
            NSLog(@"创建讨论组失败");
        }else{
            NSLog(@"temaID == %@",teamId);
            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
            NIMSessionViewController *sessionVc = [[NIMSessionViewController alloc] initWithSession:session];
            self.tabBarController.tabBar.hidden = YES;
            [self.navigationController pushViewController:sessionVc animated:YES];
        }
    }];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return initialArray;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    tableView.sectionIndexTrackingBackgroundColor= [UIColor redColor];//待考证
    tableView.sectionIndexColor = [UIColor greenColor];
    tableView.sectionIndexBackgroundColor = [UIColor lightGrayColor];
    tableView.sectionIndexMinimumDisplayRowCount = 20;//tableview总行数大于多少才显示索引
    
    static NSString *reuseIdentifier = @"HOMEBASE";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [HomeCell homeBaseCell];
    }
    
    NIMUser *user = [[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([_teamUserIdArray containsObject:user.userId]) {
        [cell setSelected:YES animated:YES];
        cell.tintColor = [UIColor lightGrayColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.nameLabel.text =user.userInfo.nickName;
    cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgView.layer.masksToBounds =YES;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:domain_img(user.userInfo.avatarUrl)]];
    
    //返回当前cell
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return initialArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSMutableArray * arr = [dataArray objectAtIndex:section];
    return arr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [initialArray objectAtIndex:section];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NIMUser *user = [[dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    if (![_teamUserIdArray containsObject:user.userId]) {
        //选中数据
        [self.selectorPatnArray addObject:[[dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]];
        NIMUser *user = [[dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        [self.selectorIdArray addObject:user.userId];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NIMUser *user = [[dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    if ([_teamUserIdArray containsObject:user.userId]) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        [cell setSelected:YES];
    }else if(self.selectorPatnArray.count > 0){
        [self.selectorPatnArray removeObject:[[dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]];
        [self.selectorIdArray removeObject:user.userId];
    }
    
    
}


//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    for (UIControl *control in self.subviews){
//        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
//            for (UIView *v in control.subviews)
//            {
//                if ([v isKindOfClass: [UIImageView class]]) {
//                    UIImageView *img=(UIImageView *)v;
//                    if (self.selected) {
//                        img.image=[UIImage imageNamed:@"选中"];
//                    }else
//                    {
//                        img.image=[UIImage imageNamed:@"未选中"];
//                    }
//                }
//            }
//        }
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
