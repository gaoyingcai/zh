//
//  TeamInfoViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/12.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"
#import <NIMSDK/NIMSDK.h>



NS_ASSUME_NONNULL_BEGIN

@interface TeamInfoViewController : BaseViewController

@property (weak, nonatomic) NSString *teamId;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewContraintHeight;

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;


@property (weak, nonatomic) IBOutlet UIButton *sessionRecordBtn;
@property (nonatomic,strong) UIButton * addBtn;
@property (nonatomic,strong) NSMutableArray * teamUserArray;


@property (nonatomic, strong)  NIMSession *session;

@end

NS_ASSUME_NONNULL_END
