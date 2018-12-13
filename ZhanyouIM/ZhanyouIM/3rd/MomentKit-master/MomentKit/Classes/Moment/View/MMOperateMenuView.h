//
//  MMOperateMenuView.h
//  MomentKit
//
//  Created by LEA on 2017/12/15.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMOperateMenuView : UIView

@property (nonatomic, assign) BOOL show;

@property (strong,nonatomic)UIImageView * imageView;
@property (strong,nonatomic)UILabel * commentLabel;
@property (strong,nonatomic)UIButton * menuBtn;

@property (nonatomic) int commentNum;

//// 赞
//@property (nonatomic, copy) void (^likeMoment)(void);
// //评论
@property (nonatomic, copy) void (^commentMoment)(void);

@end
