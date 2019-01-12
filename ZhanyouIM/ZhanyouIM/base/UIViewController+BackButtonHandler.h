//
//  UIViewController+BackButtonHandler.h
//  ZhanyouIM
//
//  Created by sxymac on 2019/1/9.
//  Copyright © 2019 Aiwozhonghua. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BackButtonHandlerProtocol <NSObject>
@optional
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end

NS_ASSUME_NONNULL_END
