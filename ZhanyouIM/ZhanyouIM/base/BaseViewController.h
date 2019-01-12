//
//  BaseViewController.h
//  JuMin
//
//  Created by 管理员 on 2017/8/31.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController


//-(void)setSlidBack;

- (void)showHUD:(NSString *)title;
- (void)hideHUD;
- (void)showTextMessage:(NSString *)message;
-(void)wangluojiance;
-(BOOL)isValidatePassword:(NSString *)password;
- (BOOL)isValidateMobile:(NSString *)mobile;
- (BOOL)isValidateIdentityCard:(NSString *)IDCardNumberl;



-(BOOL)isLogin;
-(void)setUserInfo:(NSDictionary*)dic;
-(NSMutableDictionary*)getUserinfo;

-(void)setUserIMInfo:(NSDictionary*)dic;
-(NSDictionary*)getUserIMInfo;
-(void)deleteAllUserInfo;






- (CGSize)labelAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize;
-(void)addAlertControllerToView:(UIViewController*)view actionArray:(NSArray*)actionArray;


-(void) setImageWithImageView:(UIImageView*)imgView UrlStr:(NSString*)urlStr;


-(NSString *)stringToTimestamp:(NSString*)timeStr;
-(NSString *)timestampToString:(NSString *)timeStamp;
-(NSString *)timestampToStringDay:(NSString *)timeStamp;

-(NSString *) md5: (NSString *) inPutText;

-(BOOL)checkout:(id)result;

-(void)addQueshengImageToView:(UIView*)supView imageName:(NSString*)imageName hidden:(BOOL)hidden;
@end
