//
//  HomeCell.m
//  ZhanyouIM
//
//  Created by sxymac on 2018/10/13.
//  Copyright © 2018年 Aiwozhonghua. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell

+(instancetype)homeBaseCell {
    //在类方法中加载xib文件,注意:loadNibNamed:owner:options:这个方法返回的是NSArray,所以在后面加上firstObject或者lastObject或者[0]都可以;因为我们的Xib文件中,只有一个cell
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:nil options:nil] firstObject];
}
+(instancetype)homeNoticeCell {
    //在类方法中加载xib文件,注意:loadNibNamed:owner:options:这个方法返回的是NSArray,所以在后面加上firstObject或者lastObject或者[0]都可以;因为我们的Xib文件中,只有一个cell
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:nil options:nil] objectAtIndex:1];
}
+(instancetype)homeAddCell {
    //在类方法中加载xib文件,注意:loadNibNamed:owner:options:这个方法返回的是NSArray,所以在后面加上firstObject或者lastObject或者[0]都可以;因为我们的Xib文件中,只有一个cell
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:nil options:nil] objectAtIndex:2];
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
