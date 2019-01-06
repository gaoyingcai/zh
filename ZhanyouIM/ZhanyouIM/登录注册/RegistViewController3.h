//
//  RegistViewController3.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/15.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RegistViewController3 : BaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *informationImgView;
@property (weak, nonatomic) IBOutlet UIImageView *personalImgView;

@property (strong, nonatomic) CIDetector *detector;

@property (nonatomic) BOOL returnToSession;


@end

NS_ASSUME_NONNULL_END
