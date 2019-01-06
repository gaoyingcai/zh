//
//  MomentCell.m
//  MomentKit
//
//  Created by LEA on 2017/12/14.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MomentCell.h"
#import "UIImageView+WebCache.h"

#pragma mark - ------------------ 动态 ------------------

// 最大高度限制
CGFloat maxLimitHeight = 0;

@implementation MomentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    // 头像视图
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, kBlank, kFaceWidth, kFaceWidth)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.userInteractionEnabled = YES;
    _headImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_headImageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_headImageView addGestureRecognizer:tapGesture];
    // 名字视图
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, _headImageView.top, kTextWidth, 20)];
    _nameLab.font = [UIFont boldSystemFontOfSize:17.0];
    _nameLab.textColor = kHLTextColor;
    _nameLab.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_nameLab];
    // 正文视图
    _linkLabel = kMLLinkLabel();
    _linkLabel.font = kTextFont;
    _linkLabel.delegate = self;
    _linkLabel.linkTextAttributes = @{NSForegroundColorAttributeName:kLinkTextColor};
    _linkLabel.activeLinkTextAttributes = @{NSForegroundColorAttributeName:kLinkTextColor,NSBackgroundColorAttributeName:kHLBgColor};
    [self.contentView addSubview:_linkLabel];
    // 查看'全文'按钮
    _showAllBtn = [[UIButton alloc]init];
    _showAllBtn.titleLabel.font = kTextFont;
    _showAllBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _showAllBtn.backgroundColor = [UIColor clearColor];
    [_showAllBtn setTitle:@"全文" forState:UIControlStateNormal];
    [_showAllBtn setTitleColor:kHLTextColor forState:UIControlStateNormal];
    [_showAllBtn addTarget:self action:@selector(fullTextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_showAllBtn];
    // 图片区
    _imageListView = [[MMImageListView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_imageListView];
    // 位置视图
    _locationLab = [[UILabel alloc] init];
    _locationLab.textColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
    _locationLab.font = [UIFont systemFontOfSize:13.0f];
    [self.contentView addSubview:_locationLab];
    // 时间视图
    _timeLab = [[UILabel alloc] init];
    _timeLab.textColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
    _timeLab.font = [UIFont systemFontOfSize:13.0f];
    [self.contentView addSubview:_timeLab];
    // 删除视图
    _deleteBtn = [[UIButton alloc] init];
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    _deleteBtn.backgroundColor = [UIColor clearColor];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:kHLTextColor forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteMoment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    // 评论视图
    _bgImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_bgImageView];
    _commentView = [[UIView alloc] init];
    [self.contentView addSubview:_commentView];
    // 操作视图
    _menuView = [[MMOperateMenuView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [_menuView setCommentMoment:^{
        if ([weakSelf.delegate respondsToSelector:@selector(didAddComment:)]) {
            [weakSelf.delegate didAddComment:weakSelf];
        }
    }];
    [self.contentView addSubview:_menuView];
    // 最大高度限制
    maxLimitHeight = _linkLabel.font.lineHeight * 6;
    
}

#pragma mark - setter
- (void)setCommentNum:(int)commentNum{
    _commentNum = commentNum;
    _menuView.commentNum = commentNum;
}
- (void)setMoment:(Moment *)moment
{
    _moment = moment;
    // 头像
//    _headImageView.image = [UIImage imageNamed:@"moment_head"];
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:domain_img(moment.userThumbPath)]];
    // 昵称
    _nameLab.text = moment.userName;
    // 正文
    _showAllBtn.hidden = YES;
    _linkLabel.hidden = YES;
    CGFloat bottom = _nameLab.bottom + kPaddingValue;
    CGFloat rowHeight = 0;
    if ([moment.text length]) {
        _linkLabel.hidden = NO;
        _linkLabel.text = moment.text;
        // 判断显示'全文'/'收起'
        CGSize attrStrSize = [_linkLabel preferredSizeWithMaxWidth:kTextWidth];
        CGFloat labH = attrStrSize.height;
        if (labH > maxLimitHeight) {
            if (!_moment.isFullText) {
                labH = maxLimitHeight;
                [self.showAllBtn setTitle:@"全文" forState:UIControlStateNormal];
            } else {
                [self.showAllBtn setTitle:@"收起" forState:UIControlStateNormal];
            }
            _showAllBtn.hidden = NO;
        }
        _linkLabel.frame = CGRectMake(_nameLab.left, bottom, attrStrSize.width, labH);
        _showAllBtn.frame = CGRectMake(_nameLab.left, _linkLabel.bottom + kArrowHeight, kMoreLabWidth, kMoreLabHeight);
        if (_showAllBtn.hidden) {
            bottom = _linkLabel.bottom + kPaddingValue;
        } else {
            bottom = _showAllBtn.bottom + kPaddingValue;
        }
    }
    // 图片
    _imageListView.moment = moment;
    if (moment.fileCount > 0) {
        _imageListView.origin = CGPointMake(_nameLab.left, bottom);
        bottom = _imageListView.bottom + kPaddingValue;
    }
    // 位置
    _locationLab.frame = CGRectMake(_nameLab.left, bottom, _nameLab.width, kTimeLabelH);
    _timeLab.text = [NSString stringWithFormat:@"%@",[Utility getDateFormatByTimestamp:moment.time]];
    CGFloat textW = [_timeLab.text boundingRectWithSize:CGSizeMake(200, kTimeLabelH)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:_timeLab.font}
                                                context:nil].size.width;
    if ([moment.location length]) {
        _locationLab.hidden = NO;
        _locationLab.text = moment.location;
        _timeLab.frame = CGRectMake(_nameLab.left, _locationLab.bottom+kPaddingValue, textW, kTimeLabelH);
    } else {
        _locationLab.hidden = YES;
        _timeLab.frame = CGRectMake(_nameLab.left, bottom, textW, kTimeLabelH);
    }
    _deleteBtn.frame = CGRectMake(_timeLab.right + 25, _timeLab.top, 30, kTimeLabelH);
    _deleteBtn.hidden = YES;
    bottom = _timeLab.bottom + kPaddingValue;
    // 操作视图
    _menuView.frame = CGRectMake(k_screen_width-kOperateWidth-10, _timeLab.top-(kOperateHeight-kTimeLabelH)/2, kOperateWidth, kOperateHeight);
//    _menuView.show = NO;
    // 处理评论/赞
    _commentView.frame = CGRectZero;
    _bgImageView.frame = CGRectZero;
    _bgImageView.image = nil;
    [_commentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 处理赞
    CGFloat top = 0;
//    CGFloat width = k_screen_width-kRightMargin-_nameLab.left;
    CGFloat width = k_screen_width-kRightMargin-12;
    if (_pinglunView) {
        UIView * pinglunView = [[UIView alloc]initWithFrame:CGRectMake(5, 3, width-10, 34)];
        //    pinglunView.backgroundColor= [UIColor redColor];
        [_commentView addSubview:pinglunView];
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
         [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img(moment.userThumbPath)]];
        [pinglunView addSubview:imageView];
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, width-55, 34)];
        label.layer.borderWidth = 1;
        label.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0].CGColor;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor whiteColor];
        
        
        label.textColor = [UIColor lightGrayColor];
        label.text = @" 期待您的精彩评论";
        [pinglunView addSubview:label];
        
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(40, 0, width-55, 34)];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(myDidAddComment) forControlEvents:UIControlEventTouchUpInside];
        [pinglunView addSubview:button];
        top = 40;
    }
    
    // 处理评论
    NSInteger count = [moment.commentList count];
    if (count > 0) {
        //分割线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, top + 3, width, 0.5)];
        top = top +7;
        line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        [_commentView addSubview:line];
        for (NSInteger i = 0; i < count; i ++) {
            CommentView *commentView = [[CommentView alloc]initWithFrame:CGRectMake(0, top, width, 0)];
            commentView.comment = [moment.commentList objectAtIndex:i];
            [commentView setDidClickText:^(Comment *comment) {
                if ([self.delegate respondsToSelector:@selector(didSelectComment:)]) {
                    [self.delegate didSelectComment:comment];
                }
            }];
            [commentView setDidClickLinkText:^(MLLink *link, NSString *linkText) {
                if ([self.delegate respondsToSelector:@selector(didClickLink:linkText:)]) {
                    [self.delegate didClickLink:link linkText:linkText];
                }
            }];
            [_commentView addSubview:commentView];
            // 更新
            top += commentView.height;
        }
    }
    // 更新UI
    if (top > 0) {
//        _bgImageView.frame = CGRectMake(_nameLab.left, bottom, width, top + kArrowHeight);
        _bgImageView.frame = CGRectMake(12, bottom, width, top + kArrowHeight);
//        _bgImageView.image = [[UIImage imageNamed:@"comment_bg"] stretchableImageWithLeftCapWidth:40 topCapHeight:30];
//        _commentView.frame = CGRectMake(_nameLab.left, bottom + kArrowHeight, width, top);
        _commentView.frame = CGRectMake(12, bottom + kArrowHeight, width, top);
        rowHeight = _commentView.bottom + kBlank;
    } else {
        rowHeight = _timeLab.bottom + kBlank;
    }
    
    // 这样做就是起到缓存行高的作用，省去重复计算!!!
    _moment.rowHeight = rowHeight;
}
-(void)myDidAddComment{
    [self.delegate didAddComment:self];
}
#pragma mark - 点击事件
// 查看全文/收起
- (void)fullTextClicked:(UIButton *)sender
{
    _showAllBtn.titleLabel.backgroundColor = kHLBgColor;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        self->_showAllBtn.titleLabel.backgroundColor = [UIColor clearColor];
        self->_moment.isFullText = !self->_moment.isFullText;
        if ([self.delegate respondsToSelector:@selector(didSelectFullText:)]) {
            [self.delegate didSelectFullText:self];
        }
    });
}

// 点击头像
- (void)clickHead:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(didClickProfile:)]) {
        [self.delegate didClickProfile:self];
    }
}

// 删除动态
- (void)deleteMoment:(UIButton *)sender
{
    _deleteBtn.titleLabel.backgroundColor = [UIColor lightGrayColor];
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        self->_deleteBtn.titleLabel.backgroundColor = [UIColor clearColor];
        if ([self.delegate respondsToSelector:@selector(didDeleteMoment:)]) {
            [self.delegate didDeleteMoment:self];
        }
    });
}

#pragma mark - MLLinkLabelDelegate
- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel
{
    // 点击动态正文或者赞高亮
    if ([self.delegate respondsToSelector:@selector(didClickLink:linkText:)]) {
        [self.delegate didClickLink:link linkText:linkText];
    }
}
@end


#pragma mark - ------------------ 评论(内容) ------------------
@implementation CommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _linkLabel = kMLLinkLabel();
        _linkLabel.delegate = self;
        [self addSubview:_linkLabel];
    }
    return self;
}

#pragma mark - Setter
- (void)setComment:(Comment *)comment
{
    _comment = comment;

    
    //添加用户头像和昵称
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 12, 34, 34)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img(comment.userImage)]];
    [self addSubview:imageView];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(44, 19, k_screen_width-kRightMargin-12 - 44, 20)];
    label.text = comment.userName;
    [self addSubview:label];
    
    _linkLabel.attributedText = kMLLinkLabelAttributedText(comment);
    CGSize attrStrSize = [_linkLabel preferredSizeWithMaxWidth:kTextWidth];
    _linkLabel.frame = CGRectMake(40, 50, attrStrSize.width, attrStrSize.height);
    self.height = attrStrSize.height + 60;
    
    UILabel * lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.height, k_screen_width, 1)];
    lineLabel.backgroundColor = color_lightGray;
    [self addSubview:lineLabel];
    self.height ++;
}

#pragma mark - MLLinkLabelDelegate
- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel
{
    if (self.didClickLinkText) {
        self.didClickLinkText(link,linkText);
    }
}


#pragma mark - 点击
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = kHLBgColor;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        self.backgroundColor = [UIColor clearColor];
        if (self.didClickText) {
            self.didClickText(self->_comment);
        }
    });
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor clearColor];
}

@end
