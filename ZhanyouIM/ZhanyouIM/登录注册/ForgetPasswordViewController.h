//
//  ForgetPasswordViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/17.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ForgetPasswordViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *getSmsCodeBtn;

@property (weak, nonatomic) IBOutlet UITextField *mobileNumTextField;

@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;

@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

@end

NS_ASSUME_NONNULL_END
