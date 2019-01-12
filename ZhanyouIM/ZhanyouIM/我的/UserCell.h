//
//  UserCell.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/16.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell
+(instancetype)userCell1;
+(instancetype)userCell2;
//个人信息cell
+(instancetype)userInfoCell1;
+(instancetype)userInfoCell2;
//我的资助cell
+(instancetype)aidCell;
//我的求助cell
+(instancetype)seekHelpCell;
//我的举报cell
+(instancetype)tipCell;


@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) IBOutlet UIView *starImgBackView;
@property (weak, nonatomic) IBOutlet UIImageView *userCellImg;
@property (weak, nonatomic) IBOutlet UILabel *userCellTextLabel;

//个人信息
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *userinfoTextLabel;
//我的资助
@property (weak, nonatomic) IBOutlet UILabel *aidNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aidDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *aidSumLabel;

//我的求助
@property (weak, nonatomic) IBOutlet UILabel *seekDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *seekStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *seekLabel;

//我的举报
@property (weak, nonatomic) IBOutlet UILabel *tipNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipDateLabel;



@end

NS_ASSUME_NONNULL_END
