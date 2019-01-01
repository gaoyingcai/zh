//
//  TeamInfoViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/12.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "TeamInfoViewController.h"
#import <NIMSDK/NIMSDK.h>
#import "UIImageView+WebCache.h"
#import "NewGroupViewController.h"
#import "ReportViewController.h"
#import "RecordsessionViewController.h"
#import "UserInfoViewController.h"

@interface TeamInfoViewController ()<UITextFieldDelegate>{
    float width;
    UITextField * textField;
    UIView * textFieldView;
}

@end

@implementation TeamInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    width = k_screen_width/6; //比实际照片尺寸打20 左边10 右边10

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"更多@2x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:btn]];
    
    self.sessionRecordBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:_teamId completion:^(NSError * _Nullable error, NSArray<NIMTeamMember *> * _Nullable members) {
        self->_teamUserArray = [NSMutableArray arrayWithArray:members];
        [self refreshInfo];
    }];
    
    if (!_teamUserArray) {
        _teamUserArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    
    
    
    
}
-(void)refreshInfo{
    long num_rows =_teamUserArray.count/6+1;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (num_rows/6) {
            self.backViewContraintHeight.constant = self->width*5/4*(num_rows/6);
        }else{
            self.backViewContraintHeight.constant = self->width*5/4*(num_rows/6 + 1);
        }
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    self.addBtn.frame=CGRectMake((self.teamUserArray.count%3)*width+20, self.teamUserArray.count/3*(width*5/4)+10, width-5, width*5/4-5);
    //显示所有的img
    for (int i = 0; i<self.teamUserArray.count+1; i++) {
        
        if (i == self.teamUserArray.count) {
            self.addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.addBtn setImage:[UIImage imageNamed:@"群详情添加按钮@2x.png"] forState:UIControlStateNormal];
            [self.addBtn.imageView setContentMode:UIViewContentModeScaleToFill];
            self.addBtn.frame=CGRectMake((i%6)*width +10, i/6*(width*4/3) + 10, width-20, width-20);
            [self.addBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
            [self.backView addSubview:self.addBtn];
        }else{
            
            UIView *userInfoBackView = [[UIView alloc]initWithFrame:CGRectMake((i%6)*width +10, i/6*(width*4/3) + 10, width-20, width*5/4-20)];
            [self.backView addSubview:userInfoBackView];
            UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width-20, width-20)];
            [userInfoBackView addSubview:imgView];
            UILabel *nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, width-20, width-20, width/4)];
            [userInfoBackView addSubview:nickNameLabel];
            
            NIMTeamMember *teamNumber= [self.teamUserArray objectAtIndex:i];
            NIMUser * user = [[NIMSDK sharedSDK].userManager userInfo:teamNumber.userId];
            [imgView sd_setImageWithURL:[NSURL URLWithString:domain_img(user.userInfo.avatarUrl)]];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.layer.masksToBounds = YES;
            
            nickNameLabel.text = user.userInfo.nickName;
            nickNameLabel.textColor = [UIColor darkGrayColor];
            nickNameLabel.font = [UIFont systemFontOfSize:12];
            nickNameLabel.textAlignment = NSTextAlignmentCenter;
            
            
            UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = CGRectMake(0, 0, width-20, width*5/4-20);
            button.tag = i;
            [button addTarget:self action:@selector(userInfoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [userInfoBackView addSubview:button];
            
        }
    }
}
-(void)userInfoBtnAction:(UIButton*)button{
    NIMTeamMember *teamNumber= [self.teamUserArray objectAtIndex:button.tag];
    NIMUser * user = [[NIMSDK sharedSDK].userManager userInfo:teamNumber.userId];
    
    UserInfoViewController* userInfo = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"userInfo"];
    userInfo.phone = user.userId;
    NSLog(@"%@",userInfo.phone);
    userInfo.rightBtn = YES;
    userInfo.postMessage = YES;
    [self.navigationController pushViewController:userInfo animated:YES];
}

//添加按钮，按钮的点击事件
-(void)addFriend
{
    //邀请好友加入群聊
    NewGroupViewController * newGroup = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"newGroup"];
    
    NSMutableArray *teamUserIdArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<_teamUserArray.count; i++) {
        NIMTeamMember *teamNumber= [self.teamUserArray objectAtIndex:i];
        [teamUserIdArray addObject:teamNumber.userId];
    }
    
    newGroup.teamId = _teamId;
    newGroup.teamUserIdArray = teamUserIdArray;
    [self.navigationController pushViewController:newGroup animated:YES];
    
    
}

#pragma mark --键盘的显示隐藏--
-(void)boardWillShow:(NSNotification *)notification{
    
    CGFloat curkeyBoardHeight = [[[notification userInfo]objectForKey:@"UIKeyboardBoundsUserInfoKey"]CGRectValue].size.height;
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"]CGRectValue];
    CGRect end = [[[notification userInfo]objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    if (begin.size.height>0 && begin.origin.y-end.origin.y>0) {
        [UIView animateWithDuration:0.3 animations:^{
            self->textFieldView.frame = CGRectMake(0, k_screen_height-curkeyBoardHeight - 44, k_screen_width, 44);
        }];
        
    }
    
}
-(void)boardWillHide:(NSNotification *)notification{
    [textFieldView removeFromSuperview];
    textFieldView = nil;
}

-(void)updataTeamName{
    [[NIMSDK sharedSDK].teamManager updateTeamName:textField.text teamId:_teamId completion:^(NSError * _Nullable error) {
        if (!error) {
            self.teamNameLabel.text = self->textField.text;
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -2)] animated:YES];
        }
    }];
}

- (IBAction)teamNameBtnAction:(id)sender {
    NSLog(@"评论");
    
    textFieldView = [[UIView alloc]initWithFrame:CGRectMake(0, k_screen_height, k_screen_width, 45)];
    textFieldView.backgroundColor = color_lightGray;
    [self.view addSubview:textFieldView];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, k_screen_width, 1)];
    label.backgroundColor = [UIColor lightGrayColor];
    [textFieldView addSubview:label];
    
    textField= [[UITextField alloc]initWithFrame:CGRectMake(16, 5, k_screen_width-70, 34)];
    [textField becomeFirstResponder];
    textField.backgroundColor = [UIColor whiteColor];
    textField.layer.cornerRadius = 3.0;
    textField.layer.masksToBounds = YES;
    [textFieldView addSubview:textField];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(k_screen_width-50, 5, 44, 34);
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:color_green forState:UIControlStateNormal];
    [button addTarget:self action:@selector(updataTeamName) forControlEvents:UIControlEventTouchUpInside];
    [textFieldView addSubview:button];
    
}

- (IBAction)sessionRecordAction:(id)sender {
    
    NIMSession *session = [NIMSession session:_teamId type:NIMSessionTypeTeam];
    RecordsessionViewController *records = [[RecordsessionViewController alloc] initWithSession:session];
    records.hideInputTextField = YES;
    [self.navigationController pushViewController:records animated:YES];
}

-(void)moreInfo{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet] ;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"举报该群聊" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ReportViewController * report = [[UIStoryboard storyboardWithName:@"Session" bundle:nil] instantiateViewControllerWithIdentifier:@"report"];
        report.reportId = self->_teamId;
        [self.navigationController pushViewController:report animated:YES];
    }]] ;
    [alert addAction:[UIAlertAction actionWithTitle:@"删除该群聊" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //退群
        [[NIMSDK sharedSDK].teamManager quitTeam:self->_teamId completion:^(NSError * _Nullable error) {
            if (error) {
                [self showTextMessage:@"删除失败"];
                //解散群
                [[NIMSDK sharedSDK].teamManager quitTeam:self->_teamId completion:^(NSError * _Nullable error) {
                    if (error) {
                        [self showTextMessage:@"删除失败"];
                    }else{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
        
        
        
    }]] ;
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [textField resignFirstResponder];
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
