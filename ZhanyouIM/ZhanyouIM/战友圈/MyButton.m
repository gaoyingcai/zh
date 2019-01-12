//
//  MyButton.m
//  ZhanyouIM
//
//  Created by sxymac on 2019/1/11.
//  Copyright © 2019 Aiwozhonghua. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)imageRectForContentRect:(CGRect)bounds{
    return CGRectMake(bounds.size.width/2-60, bounds.size.height/2-17.5, 35, 35);
}


@end
