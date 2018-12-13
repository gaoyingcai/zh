//
//  HomeViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/13.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : BaseViewController




@property (weak, nonatomic) IBOutlet UIView *addView;


@property (weak, nonatomic) IBOutlet UIButton *friendBtn;
@property (weak, nonatomic) IBOutlet UIView *friendLine;
@property (weak, nonatomic) IBOutlet UIButton *groupBtn;
@property (weak, nonatomic) IBOutlet UIView *groupLine;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;




@end

NS_ASSUME_NONNULL_END
