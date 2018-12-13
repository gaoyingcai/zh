//
//  UserCell.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/16.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell
+(instancetype)userCell1 {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] firstObject];
}
+(instancetype)userCell2 {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] objectAtIndex:1];
}
+(instancetype)userInfoCell1 {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] objectAtIndex:2];
}
+(instancetype)userInfoCell2 {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] objectAtIndex:3];
}
+(instancetype)aidCell {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] objectAtIndex:4];
}
+(instancetype)seekHelpCell {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] objectAtIndex:5];
}
+(instancetype)tipCell {
    return [[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:nil options:nil] objectAtIndex:6];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
