//
//  MMOperateMenuView.m
//  MomentKit
//
//  Created by LEA on 2017/12/15.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMOperateMenuView.h"
#import <UUButton.h>

@interface MMOperateMenuView ()

//@property (nonatomic, strong) UIView *menuView;
//@property (nonatomic, strong) UIButton *menuBtn;

@end

@implementation MMOperateMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _show = NO;
        [self setUpUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUpUI
{
    // 菜单容器视图
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kOperateWidth-kOperateBtnWidth, 0, kOperateWidth-kOperateBtnWidth, kOperateHeight)];
//    view.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:74.0/255.0 blue:75.0/255.0 alpha:1.0];
//    view.layer.cornerRadius = 4.0;
//    view.layer.masksToBounds = YES;
//    // 点赞
//    UUButton *btn = [[UUButton alloc] initWithFrame:CGRectMake(0, 0, view.width/2, kOperateHeight)];
//    btn.backgroundColor = [UIColor clearColor];
//    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    btn.spacing = 3;
//    [btn setTitle:@"赞" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"moment_like"] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(likeClick) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:btn];
    // 分割线
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btn.right-5, 8, 0.5, kOperateHeight-16)];
//    line.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
//    [view addSubview:line];
    // 评论
//    btn = [[UUButton alloc] initWithFrame:CGRectMake(line.right-15, 0, btn.width, kOperateHeight)];
//    btn.backgroundColor = [UIColor clearColor];
//    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    btn.spacing = 3;
//    [btn setTitle:@"评论" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"moment_comment"] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
//
    
//    [view addSubview:btn];
//    self.menuView = view;
//    [self addSubview:self.menuView];
    
    
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kOperateWidth-kOperateBtnWidth*7/4, kOperateHeight/4, kOperateBtnWidth/2, kOperateHeight/2)];
    _imageView.image = [UIImage imageNamed:@"评论@2x.png"];
    [self addSubview:_imageView];
    
    _commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(kOperateWidth-kOperateBtnWidth, 0, kOperateBtnWidth, kOperateHeight)];
    _commentLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:_commentLabel];
    
    
//    // 菜单操作按钮
    _menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(kOperateWidth-kOperateBtnWidth, 0, kOperateBtnWidth, kOperateHeight)];
    [_menuBtn setImage:[UIImage imageNamed:@"评论@2x.png"] forState:UIControlStateNormal];
    [_menuBtn setImage:[UIImage imageNamed:@"评论@2x.png"] forState:UIControlStateHighlighted];
    [_menuBtn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_menuBtn];

    
}
- (void)setCommentNum:(int )commentNum{
    if (commentNum>=0) {
        if (commentNum>999) {
            _commentLabel.text = @"999+";
        }else{
            _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)commentNum];
        }
        _menuBtn.hidden = YES;
    }else{
        _menuBtn.hidden = YES;
        _imageView.hidden = YES;
        _commentLabel.hidden = YES;
    }
}
#pragma mark - 显示/不显示
//操作视图显示不显示(赞和评论)
//- (void)setShow:(BOOL)show
//{
//    _show = show;
//    CGFloat menu_left = kOperateWidth-kOperateBtnWidth;
//    CGFloat menu_width = 0;
//    if (_show) {
//        menu_left = 0;
//        menu_width = kOperateWidth-kOperateBtnWidth;
//    }
////    self.menuView.width = menu_width;
////    self.menuView.left = menu_left;
//}

#pragma mark - 事件
//- (void)menuClick
//{
//    _show = !_show;
//    CGFloat menu_left = kOperateWidth-kOperateBtnWidth;
//    CGFloat menu_width = 0;
//    if (_show) {
//        menu_left = 0;
//        menu_width = kOperateWidth-kOperateBtnWidth;
//    }
//    [UIView animateWithDuration:0.2 animations:^{
//        self.menuView.width = menu_width;
//        self.menuView.left = menu_left;
//    }];
//
//
//}

//- (void)likeClick
//{
//    if (self.likeMoment) {
//        self.likeMoment();
//    }
//}

- (void)commentClick
{
    if (self.commentMoment) {
        self.commentMoment();
    }
}

@end

