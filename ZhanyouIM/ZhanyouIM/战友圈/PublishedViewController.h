//
//  PublishedViewController.h
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/30.
//  Copyright © 2018 Aiwozhonghua. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishedViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *photoView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeight;

@property(nullable,nonatomic,weak) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate; // 必须遵循里面的两个代理


@property (strong,nonatomic)NSString *moduleType;


@property (nonatomic,strong) UIButton * btn;
@property (nonatomic,strong) NSMutableArray * imgArray;



@end

NS_ASSUME_NONNULL_END
