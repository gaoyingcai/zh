//
//  DataService.h
//  JuMin
//
//  Created by 管理员 on 2017/9/4.
//  Copyright © 2017年 管理员. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>


typedef void(^ComoletionLoadHandle) (id result);

@interface DataService : NSObject

+ (void)requestWithGetUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block;

+ (void)requestWithPostUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block;

+ (void)requestWithUploadImageUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block;

+ (void)requestWithUploadVideoUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block;
@end
