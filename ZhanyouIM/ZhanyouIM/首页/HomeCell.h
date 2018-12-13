//
//  HomeCell.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/13.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (weak, nonatomic) IBOutlet UIButton *accessBtn;
@property (weak, nonatomic) IBOutlet UIButton *refusedBtn;





+(instancetype)homeBaseCell;
+(instancetype)homeNoticeCell;
+(instancetype)homeAddCell;
@end

NS_ASSUME_NONNULL_END
