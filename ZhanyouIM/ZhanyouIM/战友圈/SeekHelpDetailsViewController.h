//
//  SeekHelpDetailsViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeekHelpDetailsViewController : BaseViewController

@property (nonatomic, assign) int commentId;



@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewConstraintHeight;

@property (weak, nonatomic) IBOutlet UITableView *billTableView;






@end

NS_ASSUME_NONNULL_END
