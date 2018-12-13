//
//  DataService.m
//  JuMin
//
//  Created by 管理员 on 2017/9/4.
//  Copyright © 2017年 管理员. All rights reserved.
//


#import "DataService.h"



static AFHTTPSessionManager *manager;


@implementation DataService

+ (AFHTTPSessionManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化请求管理类
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 设置15秒超时 - 取消请求
        manager.requestSerializer.timeoutInterval = 15.0;
        // 编码
        manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        // 缓存策略
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        // 支持内容格式
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    });
    return manager;
    
}

+(void)requestWithGetUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block{
    
    NSLog(@"urlStr==%@",str);
    NSLog(@"%@",[NSURL URLWithString:str]);

    //对字符串进行编码
    NSString *urlStr = [domain_name(str) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    AFHTTPSessionManager *manager = [self sharedManager];
    
    [manager GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功");
        NSData *jsonData = responseObject;
        NSString *resultStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultStr);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        if (block&&[[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"0"]) {
            NSLog(@"%@",dic);
            block(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
}

+(void)requestWithPostUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block{
    //对字符串进行编码
    NSString *urlStr = [domain_name(str) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",params);
    AFHTTPSessionManager *manager = [self sharedManager];
    
    [manager POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功");
        NSData *jsonData = responseObject;
        NSString *resultStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultStr);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        if (block&&[[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"0"]) {
            NSLog(@"%@",dic);
            block(dic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败");
        NSLog(@"Error:%@",error);
    }];
    
    

}


+ (void)requestWithUploadImageUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block{
    
    
    NSLog(@"urlStr==%@",str);
    NSLog(@"%@",[NSURL URLWithString:str]);
    //对字符串进行编码
    NSString *urlStr = [domain_name(str) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPSessionManager *manager = [self sharedManager];
    //2.上传文件
    [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        
        // 1) 取当前系统时间
        NSDate *date = [NSDate date];
        // 2) 使用日期格式化工具
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        // 3) 指定日期格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateStr = [formatter stringFromDate:date];

        NSArray *imageArray = [params objectForKey:@"imageArray"];
        for (int i = 0; i < imageArray.count; i++) {
            UIImage *image = imageArray[i];
            NSData *data = UIImageJPEGRepresentation(image,1.0);
            // 4) 使用系统时间生成一个文件名
            NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg", dateStr,i + 1];
            NSString *name = [NSString stringWithFormat:@"%@%d", [params objectForKey:@"fileName"],i];
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
        }
        
        

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //打印上传进度
//        CGFloat progress = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
//        NSLog(@"%.2lf%%", progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //请求成功
        NSLog(@"上传成功：%@",responseObject);
        NSData *jsonData = responseObject;
        NSString *resultStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultStr);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                            options:NSJSONReadingMutableContainers
                            error:nil];
        
        if (block&&[[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"0"]) {
            NSLog(@"%@",dic);
            block(dic);
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //请求失败
        NSLog(@"请求失败：%@",error);
        
    }];

}



+ (void)requestWithUploadVideoUrl:(NSString *)str params:(NSDictionary *)params block:(ComoletionLoadHandle)block{
    
    
    NSLog(@"urlStr==%@",str);
    NSLog(@"%@",[NSURL URLWithString:str]);
    //对字符串进行编码
    NSString *urlStr = [domain_name(str) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPSessionManager *manager = [self sharedManager];
    //2.上传文件
    [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        // 1) 取当前系统时间
        NSDate *date = [NSDate date];
        // 2) 使用日期格式化工具
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        // 3) 指定日期格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateStr = [formatter stringFromDate:date];
        
        NSData *data = [NSData dataWithContentsOfFile:[params objectForKey:@"videoPath"]];
        
        // 4) 使用系统时间生成一个文件名
        NSString *name = [NSString stringWithFormat:@"%@.mp4",dateStr];
        [formData appendPartWithFileData:data name:@"video" fileName:name mimeType:@"video/mp4"];

//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:[params objectForKey:@"path"]] name:name fileName:[params objectForKey:@"fileName"] mimeType:@"video/mp4" error:nil];


    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //打印上传进度
        CGFloat progress = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"%.2lf%%", progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        //请求成功
        NSLog(@"上传成功：%@",responseObject);
        NSData *jsonData = responseObject;
        NSString *resultStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",resultStr);

        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];

        if (block&&[[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"0"]) {
            NSLog(@"%@",dic);
            block(dic);
        }


    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
        NSLog(@"请求失败：%@",error);
    }];
}


@end

