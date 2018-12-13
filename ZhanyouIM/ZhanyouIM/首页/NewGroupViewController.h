//
//  NewGroupViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewGroupViewController : BaseViewController
//char pinyinFirstLetter(unsigned short hanzi);

@property (strong, nonatomic) NSMutableArray *teamUserIdArray;
@property (strong, nonatomic) NSString *teamId;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
