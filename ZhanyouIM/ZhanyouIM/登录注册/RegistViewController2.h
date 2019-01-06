//
//  RegistViewController2.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/15.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RegistViewController2 : BaseViewController

@property (strong,nonatomic) NSString *uid;
@property (strong,nonatomic) NSString *phone;

@property (strong,nonatomic) NSString *source;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic) BOOL returnToSession;
@property(copy,nonatomic)void(^passValueBlock)(NSArray* array);

@end

NS_ASSUME_NONNULL_END
