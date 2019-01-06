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
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - ------------------ 小图List显示视图 ------------------

@interface MMImageListView ()

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
    for (NSInteger i = 0; i < count; i++)
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
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString * urlStr = domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source"]);
                videoImgView.image = [self getVideoPreViewImageWithPath:[NSURL URLWithString:urlStr]];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    videoImgView.image = [self getVideoPreViewImageWithPath:[NSURL URLWithString:urlStr]];
//                });
                

            });
//            videoImgView.image = [UIImage imageNamed:@"1.png"];
            [imagebackView addSubview:videoImgView];
            
            UIImageView * beginImgView = [[UIImageView alloc]initWithFrame:CGRectMake(k_screen_width*9/64-20, k_screen_width/4-20, 40, 40)];
            beginImgView.image = [UIImage imageNamed:@"player.png"];
            [videoImgView addSubview:beginImgView];
            
        }else{
            //单张图片需计算实际显示size
            if (count == 1) {
                CGSize singleSize = [Utility getSingleSize:CGSizeMake(moment.singleWidth, moment.singleHeight)];
                frame = CGRectMake(0, 0, singleSize.width, singleSize.height);
            }
            imagebackView = [self viewWithTag:1000+i];
            imagebackView.hidden = NO;
            imagebackView.frame = frame;
            NSLog(@"%@",domain_img([imageArray objectAtIndex:i]));
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imagebackView.frame.size.width, imagebackView.frame.size.width)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:domain_img([[imageArray objectAtIndex:i]objectForKey:@"path_source_img"])]];
            [imagebackView addSubview:imageView];
        }
    }
    self.width = kTextWidth;
    self.height = imagebackView.bottom;
}

#pragma mark - 小图单击
- (void)singleTapSmallViewCallback:(MMImageBackView *)imagebackView
{
    _previewView = [[MMImagePreviewView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow addSubview:_previewView];
    NSDictionary * dic = [_moment.imageArray objectAtIndex:0];
//    if ([domain_img([[_moment.imageArray objectAtIndex:0]objectForKey:@"path_source"])containsString:@".mp4"]){
    if ([[dic allKeys]containsObject:@"path_source"]){
        
        NSString *urlStr = domain_img([[_moment.imageArray objectAtIndex:0]objectForKey:@"path_source"]);
//        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:[NSURL URLWithString:urlStr]]];
//        playerLayer.masksToBounds= YES;
//        playerLayer.borderColor = [UIColor blackColor].CGColor;
//        playerLayer.frame = CGRectMake(0, 0, _previewView.width , _previewView.height);
        
        _PlayerVC = [[AVPlayerViewController alloc] init];
        _PlayerVC.view.backgroundColor = [UIColor clearColor];
        _PlayerVC.showsPlaybackControls = NO;
//        [self.clipView.layer addSublayer:playerLayer];
        _PlayerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:urlStr]];
        _PlayerVC.view.frame = CGRectMake(0, 0, _previewView.width , _previewView.height);
//        convertRect = [[_PlayerVC.view superview] convertRect:_PlayerVC.view.frame toView:app.keyWindow];
        
        [_previewView.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        // 添加子视图
        CGRect convertRect;
        [_previewView.pageControl removeFromSuperview];
         //转换Frame
        convertRect = [[_previewView superview] convertRect:_previewView.frame toView:app.keyWindow];
        // 添加
        MMScrollView *scrollView = [[MMScrollView alloc] initWithFrame:CGRectMake(0, 0, _previewView.width, _previewView.height)];
        scrollView.tag = 100;
        scrollView.maximumZoomScale = 2.0;
        scrollView.contentRect = convertRect;
        // 单击
        [scrollView setTapBigView:^(MMScrollView *scrollView){
//            [playerLayer.player pause];
//            playerLayer.player = nil;
            [self singleTapBigViewCallback:scrollView];
        }];
        // 长按
        [scrollView setLongPressBigView:^(MMScrollView *scrollView){
            [self longPresssBigViewCallback:scrollView];
        }];
        [scrollView addSubview:_PlayerVC.view];
//        [scrollView.layer addSublayer:playerLayer];
        [_previewView addSubview:scrollView];

        [UIView animateWithDuration:0.3 animations:^{
            self->_previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            [scrollView updateOriginRect];
        }];
        
        // 更新offset
        CGPoint offset = _previewView.scrollView.contentOffset;
        offset.x = k_screen_width;
        _previewView.scrollView.contentOffset = offset;
//        _PlayerVC.delegate = [self viewControllerSupportView:self];
        [self->_PlayerVC.player play];
//        [playerLayer.player play];
    }else{
        // 解除隐藏
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
                }];
            } else {
                [scrollView updateOriginRect];
            }
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

#pragma mark - 大图单击||长按
- (void)singleTapBigViewCallback:(MMScrollView *)scrollView
{
    if (_PlayerVC) {
        [_PlayerVC.player pause];
        _PlayerVC= nil;
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
