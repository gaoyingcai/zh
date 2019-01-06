//
//  SessionViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/11.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NIMSessionListViewController.h"

@interface SessionViewController : NIMSessionListViewController<NIMLoginManagerDelegate>{
    UIView *backView;
    NSMutableDictionary * announcementDic;
}

@property (weak, nonatomic) IBOutlet UILabel *gonggaoTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBottom;


@end
