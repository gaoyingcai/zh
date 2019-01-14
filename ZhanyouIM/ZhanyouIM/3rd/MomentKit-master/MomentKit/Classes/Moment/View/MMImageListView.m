//
//  MMImageListView.m
//  MomentKit
//
//  Created by LEA on 2017/12/14.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMImageListView.h"
#import "MMImagePreviewView.h"
#import "UIImageView+WebCache.h"
//#import "SDImageCache.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

#pragma mark - ------------------ 小图List显示视图 ------------------

@interface MMImageListView (){
    MBProgressHUD *_hud;//加载提示控件
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
}

// 图片视图数组
@property (nonatomic, strong) NSMutableArray *imageViewsArray;
// 预览视图
@property (nonatomic, strong) MMImagePreviewView *previewView;
@property (nonatomic,strong)AVPlayerViewController * PlayerVC;

@end

@implementation MMImageListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 小图(九宫格)
        _imageViewsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
            MMImageBackView *imagebackView = [[MMImageBackView alloc] initWithFrame:CGRectZero];
            imagebackView.tag = 1000 + i;
            [imagebackView setTapSmallView:^(MMImageBackView *imagebackView){
                [self singleTapSmallViewCallback:imagebackView];
            }];
            [_imageViewsArray addObject:imagebackView];
            [self addSubview:imagebackView];
        }
        // 预览视图
//        _previewView = [[MMImagePreviewView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return self;
}

#pragma mark - Setter
- (void)setMoment:(Moment *)moment
{
    _moment = moment;
    for (MMImageBackView *imagebackView in _imageViewsArray) {
        imagebackView.hidden = YES;
    }
    // 图片区
    NSInteger count = moment.fileCount;
    if (count == 0) {
        self.size = CGSizeZero;
        return;
    }
    // 更新视图数据
    _previewView.pageNum = count;
    _previewView.scrollView.contentSize = CGSizeMake(_previewView.width*count, _previewView.height);
    // 添加图片
    MMImageBackView *imagebackView = nil;
    //图片地址
    NSLog(@"moment == %@",moment);
    NSLog(@"moment.imageArray == %@",moment.imageArray);
    for (int i = 0; i<moment.imageArray.count; i++) {
        NSLog(@"%@",[moment.imageArray objectAtIndex:i]);
    }
    NSMutableArray * imageArray = [NSMutableArray arrayWithArray:moment.imageArray];
    for (NSInteger i = 0; i < imageArray.count; i++)
    {
        if (i > 8) {
            break;
        }
        NSInteger rowNum = i/3;
        NSInteger colNum = i%3;
        if(count == 4) {
            rowNum = i/2;
            colNum = i%2;
        }
        
        CGFloat imageX = colNum * (kImageWidth + kImagePadding);
        CGFloat imageY = rowNum * (kImageWidth + kImagePadding);
        CGRect frame = CGRectMake(imageX, imageY, kImageWidth, kImageWidth);
        
        NSDictionary * dic = [imageArray objectAtIndex:i];
        if ([[dic allKeys]containsObject:@"path_source"]) {
            
            if (count == 1) {
                frame = CGRectMake(0, 0, k_screen_width*9/32, k_screen_width/2);
            }
            imagebackView = [self viewWithTag:1000+i];
            imagebackView.hidden = NO;
            imagebackView.frame = frame;

            UIImageView *videoImgView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, k_screen_width*9/32 , k_screen_width/2)];
            videoImgView.backgroundColor = [UIColor clearColor];
            
            
            if ([[dic allKeys] containsObject:@"path_source_img_local"]) {
                videoImgView.image = (UIImage*)[dic objectForKey:@"path_source_img_local"];
                [imagebackView addSubview:videoImgView];
            }else{
                NSString * urlStr = domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source_img"]);
                [videoImgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];

//                 [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
//                [videoImgView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"loding.png"]];
                [imagebackView addSubview:videoImgView];
            }
            
            UIImageView * beginImgView = [[UIImageView alloc]initWithFrame:CGRectMake(k_screen_width*9/64-20, k_screen_width/4-20, 40, 40)];
            beginImgView.image = [UIImage imageNamed:@"player.png"];
            [videoImgView addSubview:beginImgView];
            
        }else{
            //单张图片需计算实际显示size
            
            if ([[dic allKeys] containsObject:@"local_img"]) {
                imagebackView = [self viewWithTag:1000+i];
                imagebackView.hidden = NO;
//                CGFloat img_width = (k_screen_width-60)/3-5;
//                CGFloat img_width = (k_screen_width-40)/3;
                CGFloat img_width =  (k_screen_width-40)/3;
//                (i%3)*width+20, i/3*width+10, width-5, width-5
//                imagebackView.frame = CGRectMake(((k_screen_width-60)/3-5)*(i%3)+20, ((k_screen_width-60)/3-5) *(i/3), (k_screen_width-60)/3-5, (k_screen_width-60)/3-5);
                imagebackView.frame = CGRectMake((i%3)*img_width+5, i/3*img_width+10, img_width-5, img_width-5);
                NSLog(@"%@",domain_img([imageArray objectAtIndex:i]));
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imagebackView.frame.size.width, imagebackView.frame.size.width)];
                imageView.image = (UIImage*)[dic objectForKey:@"local_img"];
                [imagebackView addSubview:imageView];
            }else{
                if (count == 1) {
                    CGSize singleSize = [Utility getSingleSize:CGSizeMake(moment.singleWidth, moment.singleHeight)];
                    frame = CGRectMake(0, 0, singleSize.width, singleSize.height);
                    
                    imagebackView = [self viewWithTag:1000+i];
                    imagebackView.hidden = NO;
                    imagebackView.frame = frame;
                    NSLog(@"%@",domain_img([imageArray objectAtIndex:i]));
                    
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imagebackView.frame.size.width, imagebackView.frame.size.height)];
//                    [imageView setContentMode:UIViewContentModeScaleAspectFill];
//                    imageView.clipsToBounds = YES;
                    
//                [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source_img"])]];
                    
//                [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source_img"])] placeholderImage:[UIImage imageNamed:@"loading_1.png"]];
                    [imagebackView addSubview:imageView];
                }else{
                    imagebackView = [self viewWithTag:1000+i];
                    imagebackView.hidden = NO;
                    imagebackView.frame = frame;
                    NSLog(@"%@",domain_img([imageArray objectAtIndex:i]));
                    
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imagebackView.frame.size.width, imagebackView.frame.size.width)];
//                [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source_img"])]];
                    
//                [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source_img"])] placeholderImage:[UIImage imageNamed:@"loding.png"]];
                    [imagebackView addSubview:imageView];
                }
                
            }
            
        }
    }
    self.width = kTextWidth;
    self.height = imagebackView.bottom;
}

#pragma mark - 小图单击
- (void)singleTapSmallViewCallback:(MMImageBackView *)imagebackView
{
    [self hideHUD];
    
    if (playerLayer) {
        [playerLayer.player pause];
        playerLayer= nil;
        MMScrollView *scaleScrollview = (MMScrollView*)self.previewView.scrollView;
        [UIView animateWithDuration:0.3 animations:^{
            self->_previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            self->_previewView.pageControl.hidden = YES;
            scaleScrollview.contentRect = scaleScrollview.contentRect;
            self->_previewView.scrollView.zoomScale = 1.0;
        } completion:^(BOOL finished) {
            [self->_previewView removeFromSuperview];
        }];
        return;
    }
    
    
    
    
    
    
    
    _previewView = [[MMImagePreviewView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow addSubview:_previewView];
    NSDictionary * dic = [_moment.imageArray objectAtIndex:0];
    // 清空
    [_previewView.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 添加子视图
    NSInteger index = imagebackView.tag-1000;
    NSInteger count = _moment.fileCount;
    CGRect convertRect;
    if (count == 1) {
        [_previewView.pageControl removeFromSuperview];
    }
    for (NSInteger i = 0; i < count; i ++)
    {
        // 转换Frame
        MMImageBackView *pImageBackView = (MMImageBackView *)[self viewWithTag:1000+i];
        
        NSArray * imageViewArray =[pImageBackView subviews];
        UIImageView *pImageView = nil;
        for (UIView * view in imageViewArray) {
            if ([view isKindOfClass:[UIImageView class]]) {
                pImageView = (UIImageView*)view;
            }
        }
        
        convertRect = [[pImageView superview] convertRect:pImageView.frame toView:app.keyWindow];
        // 添加
        MMScrollView *scrollView = [[MMScrollView alloc] initWithFrame:CGRectMake(i*_previewView.width, 0, _previewView.width, _previewView.height)];
        scrollView.tag = 100+i;
        scrollView.maximumZoomScale = 2.0;
        scrollView.image = pImageView.image;
        scrollView.contentRect = convertRect;
        // 单击
        [scrollView setTapBigView:^(MMScrollView *scrollView){
            [self singleTapBigViewCallback:scrollView];
        }];
        // 长按
        [scrollView setLongPressBigView:^(MMScrollView *scrollView){
            [self longPresssBigViewCallback:scrollView];
        }];
        [_previewView.scrollView addSubview:scrollView];
        if (i == index) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self->_previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
                self->_previewView.pageControl.hidden = NO;
                self->_previewView.pageControl.currentPage = index;
                [scrollView updateOriginRect];
            } completion:^(BOOL finished) {
                
                if ([[dic allKeys]containsObject:@"path_source"]){
                    if ([[dic allKeys]containsObject:@"path_source_img_local"]) {
                        NSString *urlStr =[dic objectForKey:@"path_source"];
                        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:[NSURL fileURLWithPath:urlStr]]];
                        playerLayer.delegate = self;
                        playerLayer.masksToBounds= YES;
                        playerLayer.borderColor = [UIColor blackColor].CGColor;
                        playerLayer.frame = CGRectMake(0, 0, self->_previewView.width , self->_previewView.height);
                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:urlStr]];
                        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
                        playerLayer.player = [AVPlayer playerWithPlayerItem:playerItem];
                        [self->_previewView.scrollView.layer addSublayer:playerLayer];
                        [playerLayer.player play];
//                        [self showHUD:@"努力加载中" ToView:scrollView];
                        // 单击
                        [scrollView setTapBigView:^(MMScrollView *scrollView){
                            [playerLayer.player pause];
                            [playerLayer removeFromSuperlayer];
                            [self singleTapBigViewCallback:scrollView];
                        }];
                    }else{
//                        UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self->_previewView.width , self->_previewView.height)];
                        NSString *urlStr = domain_img([dic objectForKey:@"path_source"]);
                        self->playerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:[NSURL URLWithString:urlStr]]];
                        self->playerLayer.delegate = self;
                        self->playerLayer.masksToBounds= YES;
                        self->playerLayer.borderColor = [UIColor blackColor].CGColor;
                        self->playerLayer.frame = CGRectMake(0, 0, self->_previewView.width , self->_previewView.height);
                        self->playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
                        //                    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
                        [self->playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
                        self->playerLayer.player = [AVPlayer playerWithPlayerItem:self->playerItem];
//                        [backview.layer addSublayer:self->playerLayer];
//                        [scrollView addSubview:backview];
                        [self->_previewView.scrollView.layer addSublayer:self->playerLayer];
//                        [self->_previewView.scrollView addSubview:scrollView];
//                        [playerLayer.player play];
                        [self showHUD:@"努力加载中" ToView:self.previewView];
                        // 单击
                        [scrollView setTapBigView:^(MMScrollView *scrollView){
                            [self->playerLayer.player pause];
                            [self->playerLayer removeFromSuperlayer];
                            [self singleTapBigViewCallback:scrollView];
                        }];
                    }
                }
            }];
        } else {
            [scrollView updateOriginRect];
        }
        // 更新offset
        CGPoint offset = _previewView.scrollView.contentOffset;
        offset.x = index * k_screen_width;
        _previewView.scrollView.contentOffset = offset;
    }
    _previewView.scrollView.contentSize = CGSizeMake(_moment.imageArray.count*_previewView.size.width, _previewView.size.height);
    _previewView.pageControl.numberOfPages = _moment.imageArray.count;
    NSLog(@"%@",_previewView);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);

        if (timeInterval > totalDuration*9/10) {
            [playerLayer.player play];
            [self hideHUD];
        }
    }
}
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[playerLayer.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


//显示hud加载提示
- (void)showHUD:(NSString *)title ToView:(UIView*)view
{
    if (_hud == nil) {
        _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    _hud.label.text = title;
    //有无灰色的遮罩视图
//    _hud.dimBackground = NO;
}
- (void)hideHUD
{
    if (_hud) {
        [_hud removeFromSuperview];
    }
    _hud = nil;
}

#pragma mark - 大图单击||长按
- (void)singleTapBigViewCallback:(MMScrollView *)scrollView
{
    [self hideHUD];
    if (playerLayer) {
        [playerLayer.player pause];
        playerLayer= nil;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self->_previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self->_previewView.pageControl.hidden = YES;
        scrollView.contentRect = scrollView.contentRect;
        scrollView.zoomScale = 1.0;
    } completion:^(BOOL finished) {
        [self->_previewView removeFromSuperview];
    }];
}
- (UIViewController *)viewControllerSupportView:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)longPresssBigViewCallback:(MMScrollView *)scrollView
{
    NSLog(@"长按");
}
//获取视频的第一帧返回y图片
- (UIImage*) getVideoPreViewImageWithPath:(NSURL *)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time= CMTimeMakeWithSeconds(0.0, 600);
    NSError *error= nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img= [[UIImage alloc] initWithCGImage:image];
    return img;
}
@end

#pragma mark - ------------------ 单个小图显示视图 ------------------
@implementation MMImageBackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds  = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCallback:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)singleTapGestureCallback:(UIGestureRecognizer *)gesture
{
    if (self.tapSmallView) {
        self.tapSmallView(self);
    }
}

@end
