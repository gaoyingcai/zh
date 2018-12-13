//
//  SelectAddressView.m
//  JuMin
//
//  Created by 管理员 on 2017/9/4.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import "SelectAddressView.h"

@implementation SelectAddressView
{
    UIPickerView * _pickerView;
    UIButton * _button;
    NSArray * _provinceArray;
    NSMutableArray * _cityArray;
    NSMutableArray * _areaArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)creatAddressView{
    [self loadDate];
    
    self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(10, 10,k_view_width(self)-20 , k_view_height(self)-20)];
    view.layer.cornerRadius=3.0;
    view.layer.masksToBounds=YES;
    view.backgroundColor=[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    [self addSubview:view];
    
    _pickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0 ,40, k_view_width(self), k_view_height(self)-40)];
    _pickerView.backgroundColor=[UIColor whiteColor];
    [view addSubview:_pickerView];
    _pickerView.delegate=self;
    _pickerView.dataSource=self;
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width*2/3-1, 39)];
    label.backgroundColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"地区选择";
    [view addSubview:label];
    
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(view.frame.size.width*2/3, 0, view.frame.size.width/3, 39);
    button.backgroundColor=[UIColor whiteColor];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:46/255.0 green:214/255.0 blue:203/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(quedingAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}
-(void)loadDate{
    
    _provinceArray=[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"address" ofType:@"plist"]];
    _cityArray=[NSMutableArray arrayWithCapacity:0];
    _areaArray=[NSMutableArray arrayWithCapacity:0];
    
    [_cityArray addObjectsFromArray:[[_provinceArray objectAtIndex:0] objectForKey:@"sub"]];
    [_areaArray addObjectsFromArray:[[_cityArray objectAtIndex:0]objectForKey:@"sub"]];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger result=0;
    switch (component) {
        case 0:
            result =_provinceArray.count;
            break;
        case 1:
            result=_cityArray.count;
            break;
        case 2:
            result=_areaArray.count;
            break;
        default:
            break;
    }
    return result;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        
        pickerLabel = [[UILabel alloc] init];
        [pickerLabel setTextColor:[UIColor blackColor]];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:17.0f]];
    }
    
    switch (component) {
        case 0:
            pickerLabel.text=[NSString stringWithFormat:@"%@",_provinceArray[row][@"name"]];
            break;
        case 1:
            pickerLabel.text=[NSString stringWithFormat:@"%@",_cityArray[row][@"name"]];
            break;
        case 2:
            pickerLabel.text=[NSString stringWithFormat:@"%@",_areaArray[row][@"name"]];
            break;
        default:
            break;
    }
    
    return pickerLabel;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    
    switch (component) {
        case 0:
            [_cityArray removeAllObjects];
            [_areaArray removeAllObjects];
            
            [_cityArray addObjectsFromArray:[[_provinceArray objectAtIndex:row] objectForKey:@"sub"]];
            
            if (_cityArray.count) {
                [_areaArray addObjectsFromArray:[[_cityArray objectAtIndex:0] objectForKey:@"sub"]];
            }
            
            [_pickerView reloadComponent:1];
            [_pickerView reloadComponent:2];
            
            [_pickerView selectRow:0 inComponent:1 animated:YES];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
            
            break;
        case 1:
            [_areaArray removeAllObjects];
            
            if (_cityArray.count) {
                [_areaArray addObjectsFromArray:[[_cityArray objectAtIndex:row] objectForKey:@"sub"]];
            }
            
            
            
            [_pickerView reloadComponent:2];
            
            [_pickerView selectRow:0 inComponent:2 animated:YES];
            
            break;
            
        default:
            break;
    }
    
}
-(void)quedingAction{
    
    NSString*addressStr;
    NSString*addressCode;
    
    NSInteger row1=[_pickerView selectedRowInComponent:0];
    NSInteger row2=[_pickerView selectedRowInComponent:1];
    NSInteger row3=[_pickerView selectedRowInComponent:2];
    
    
    if (_cityArray.count>0) {
        if (_areaArray.count>0) {
            addressStr=[NSString stringWithFormat:@"%@%@%@",_provinceArray[row1][@"name"],_cityArray[row2][@"name"],_areaArray[row3][@"name"]];
            addressCode=[NSString stringWithFormat:@"%@",_areaArray[row3][@"id"]];
        }else{
            addressStr=[NSString stringWithFormat:@"%@%@",_provinceArray[row1][@"name"],_cityArray[row2][@"name"]];
            addressCode=[NSString stringWithFormat:@"%@",_cityArray[row2][@"id"]];
        }
    }else{
        addressStr=[NSString stringWithFormat:@"%@",_provinceArray[row1][@"name"]];
        addressCode=[NSString stringWithFormat:@"%@",_provinceArray[row1][@"id"]];
    }
    
    
//    if (_areaArray.count>0) {
//        addressStr=[NSString stringWithFormat:@"%@%@%@",_provinceArray[row1][@"name"],_cityArray[row2][@"name"],_areaArray[row3][@"name"]];
//        addressCode=[NSString stringWithFormat:@"%@",_areaArray[row3][@"id"]];
//    }else{
//        addressStr=[NSString stringWithFormat:@"%@%@",_provinceArray[row1][@"name"],_cityArray[row2][@"name"]];
//        addressCode=[NSString stringWithFormat:@"%@",_cityArray[row2][@"id"]];
//    }

    
    NSDictionary*dic=@{notification_address_key:addressStr};
    
    [[NSNotificationCenter defaultCenter]postNotificationName:notification_address object:nil userInfo:dic];
    
}




@end
