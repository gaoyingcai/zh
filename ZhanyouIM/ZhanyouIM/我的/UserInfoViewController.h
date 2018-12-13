//
//  UserInfoViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/17.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) NSString *phone;

@property (assign, nonatomic) BOOL loginOut;
@property (assign, nonatomic) BOOL rightBtn;
@property (assign, nonatomic) BOOL postMessage;

@end

NS_ASSUME_NONNULL_END
