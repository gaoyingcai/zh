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
//        NSString *resultStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        /*
         针对获取用户信息   /api/common/getIndexData
         -1 用户需要缴纳费用 需要跳转到缴费界面
         -2 用户信息未填写完整 需要跳转到用户信息界面
         -3 用户头像信息没有完整- 需要跳转到上传照片界面
         -4 需要缴纳年费！
         -5 无缴费记录。如已缴费，请联系客服操作！若没有缴费，请先缴纳费用！谢谢合作！
         */
        NSLog(@"%@",dic);
        NSString *status = [NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]];
        if (block && [status intValue] <=1) {
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
            UIImage *sourceImage = imageArray[i];
            NSLog(@"%f",sourceImage.size.width);
            NSLog(@"%f",sourceImage.size.height);
            NSLog(@"%f",sourceImage.scale);
            UIImage *image = [self compressImage:sourceImage toTargetWidth:640];
            NSLog(@"%f",image.size.width);
            NSLog(@"%f",image.size.height);
            NSLog(@"%f",image.scale);
            NSData *data = UIImageJPEGRepresentation(image,1);
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

//压缩图片
/*
 “压” 是指文件体积变小，但是像素数不变，长宽尺寸不变，那么质量可能下降。
 UIImageJPEGRepresentation
 
 “缩” 是指文件的尺寸变小，也就是像素数减少，而长宽尺寸变小，文件体积同样会减小。
 */
+ (UIImage*)compressImage:(UIImage*)sourceImage toTargetWidth:(CGFloat)targetWidth {
    CGSize imageSize = sourceImage.size;
    if(imageSize.width>targetWidth) {
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        CGFloat targetHeight = (targetWidth / width) * height;
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [sourceImage drawInRect:CGRectMake(0,0, targetWidth, targetHeight)];
        UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }else{
        return sourceImage;
    }
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

