//
//  SeekHelpViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "SeekHelpViewController.h"
#import "UserCell.h"
#import "DataService.h"
#import "PublishedViewController.h"

@interface SeekHelpViewController (){
    NSMutableArray *dataArray;
    UILabel *cellLabel;
}

@end

@implementation SeekHelpViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tianjia@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addMoment)];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = color_lightGray;
    self->dataArray = [NSMutableArray arrayWithCapacity:0];
    
    
    NSDictionary * paramDic = @{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"]};
    [DataService requestWithPostUrl:@"/api/self/supportMsg" params:paramDic block:^(id result) {
        if ([self checkout:result]) {
            NSLog(@"%@",result);
            self->dataArray = [result objectForKey:@"data"];
            [self->_tableView reloadData];
        }
    }];
}
- (void)addMoment
{
    NSLog(@"新增");
    PublishedViewController *published = [[UIStoryboard storyboardWithName:@"Circle" bundle:nil] instantiateViewControllerWithIdentifier:@"published"];
    published.moduleType = @"3";
    [self.navigationController pushViewController:published animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.backgroundColor = color_lightGray;
    
    static NSString *reuseIdentifier = @"SEEKHELP";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [UserCell seekHelpCell];
    }
    
    cell.seekDateLabel.text = [self timestampToString:[[dataArray objectAtIndex:indexPath.row]objectForKey:@"add_time"]];
    NSString * contentStr = [NSString stringWithFormat:@"求助项目:%@",[[dataArray objectAtIndex:indexPath.row]objectForKey:@"content"]];
    NSString * verifyMsgStr = [NSString stringWithFormat:@"审核结果:%@",[[dataArray objectAtIndex:indexPath.row]objectForKey:@"verify_msg"]];
//    cell.seekTextView.backgroundColor = [UIColor redColor];
    cell.seekLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.seekLabel.numberOfLines = 0;
    cell.seekLabel.text = [NSString stringWithFormat:@"%@\n%@",contentStr,verifyMsgStr];
    cellLabel = cell.seekLabel;
    
    NSString * str = [NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row]objectForKey:@"status"]];
    if ([str isEqualToString:@"0"]) {
        cell.seekStatusLabel.text = @"正在审核";
        cell.seekStatusLabel.textColor = [UIColor colorWithRed:150/255.0 green:220/255.0 blue:163/255.0 alpha:1];
    }else if ([str isEqualToString:@"1"]){
        cell.seekStatusLabel.text =@"通过";
        cell.seekStatusLabel.textColor = color_green;
    }else if ([str isEqualToString:@"2"]){
        cell.seekStatusLabel.text = @"失败";
        cell.seekStatusLabel.textColor = [UIColor redColor];
    }
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize attrStrSize = [self getSpaceLabelHeight:cellLabel.text withFont:cellLabel.font withWidth:cellLabel.width];
    NSLog(@"%@",cellLabel.text);
    NSLog(@"%f",attrStrSize.height);
    return attrStrSize.height+50;

}
-(CGSize)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping; //截断方式
    paraStyle.alignment = NSTextAlignmentLeft; //对齐方式
    paraStyle.paragraphSpacingBefore = 15.0f;  //段落间距
    paraStyle.lineSpacing = 10.0f; //行间距
    paraStyle.hyphenationFactor = 1.0; //连字符属性
    paraStyle.firstLineHeadIndent = 0.0; //每段首行缩进
    paraStyle.headIndent = 0; //首行缩进
    paraStyle.tailIndent = 0; //右侧缩进或显示宽度
    //, NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle};
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return  size;
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
