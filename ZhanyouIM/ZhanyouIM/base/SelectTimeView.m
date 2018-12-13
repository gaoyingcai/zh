//
//  SelectTimeView.m
//  JuMin
//
//  Created by 管理员 on 2017/10/17.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import "SelectTimeView.h"
@implementation SelectTimeView
{
    UIDatePicker *datePicker;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)creatTimeView{
    //创建一个UIPickView对象
    
    self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(10, 10, k_view_width(self)-20,k_view_height(self)-20)];
    view.layer.cornerRadius=3.0;
    view.layer.masksToBounds=YES;
    view.backgroundColor=[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    [self addSubview:view];
    
    datePicker = [[UIDatePicker alloc]init];
    //自定义位置
    datePicker.frame = CGRectMake(0, 40, k_view_width(self), k_view_height(self)-40);
    //设置背景颜色
    datePicker.backgroundColor = [UIColor whiteColor];
    //datePicker.center = self.center;
    //设置本地化支持的语言（在此是中文)
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    //显示方式是只显示年月日
    datePicker.datePickerMode = UIDatePickerModeDate;
    //放在盖板上
    [view addSubview:datePicker];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width*2/3-1, 39)];
    label.backgroundColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"日期选择";
    [view addSubview:label];

    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(view.frame.size.width*2/3, 0, view.frame.size.width/3, 39);
    button.backgroundColor=[UIColor whiteColor];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:46/255.0 green:214/255.0 blue:203/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(quedingAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}
-(void)quedingAction{


    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString  * string = [dateFormatter stringFromDate:date];
//    NSLog(@"%@",string);


    NSDictionary*dic=@{notification_data_key:string};

    [[NSNotificationCenter defaultCenter]postNotificationName:notification_data object:nil userInfo:dic];

}

@end
