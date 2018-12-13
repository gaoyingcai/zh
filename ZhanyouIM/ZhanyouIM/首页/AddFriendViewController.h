//
//  AddFriendViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/23.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddFriendViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchMeBtn;
@property (weak, nonatomic) IBOutlet UIView *searchMeLine;
@property (weak, nonatomic) IBOutlet UIButton *mySearchBtn;
@property (weak, nonatomic) IBOutlet UIView *mySearchLine;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

NS_ASSUME_NONNULL_END
