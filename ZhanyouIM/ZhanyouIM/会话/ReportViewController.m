//
//  Report ViewController.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/19.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "ReportViewController.h"
#import "DataService.h"

@interface ReportViewController ()<UITextViewDelegate>

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)reportAction:(id)sender {
    if (_textView.text.length>0&&![_textView.text isEqualToString:@"请输入举报内容..."]) {
        
        NSString* type;
        if (_isPerson) {
            type = @"person";
        }else{
            type = @"team";
        }
        
        
        NSDictionary * paramDic = @{@"uid":[[[NSUserDefaults standardUserDefaults] objectForKey:user_defaults_user] objectForKey:@"uid"],
                                    @"reason":_textView.text,
                                    @"type":type,
                                    @"report_uid":_reportId
                                    };
        [DataService requestWithPostUrl:@"/api/user/report" params:paramDic block:^(id result) {
            if (result) {
                [self showTextMessage:@"举报成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        [self showTextMessage:@"请输入举报内容"];
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@"请输入举报内容..."]) {
        textView.text=@"";
        _textView.textColor = [UIColor blackColor];
    }
    return YES;
}

@end
