//
//  AddFriendReqViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2019/1/6.
//  Copyright © 2019 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddFriendReqViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userNum;
@property (weak, nonatomic) IBOutlet UITextView *requestInfo;


@property (strong, nonatomic) NSString * userImgUrl;
@property (strong, nonatomic) NSString * userNameStr;
@property (strong, nonatomic) NSString * userNumStr;





@end

NS_ASSUME_NONNULL_END
