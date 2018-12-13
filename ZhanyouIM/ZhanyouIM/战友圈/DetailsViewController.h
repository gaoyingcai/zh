//
//  Details ViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/29.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int commentId;

@end

NS_ASSUME_NONNULL_END
