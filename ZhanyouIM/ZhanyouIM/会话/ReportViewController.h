//
//  Report ViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/11/19.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportViewController : BaseViewController
@property (assign, nonatomic) BOOL isPerson;
@property (strong, nonatomic) NSString *reportId;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

NS_ASSUME_NONNULL_END
