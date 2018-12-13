//
//  CircleViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/11.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CircleViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSString *content;


@property (assign, nonatomic) BOOL hideTabBar;

@end
