
//
//  ImagePreview.m
//  DKChat
//
//  Created by liudukun on 16/7/6.
//  Copyright © 2016年 com.ldk. All rights reserved.
//

#import "ImagePreview.h"

static CGFloat const ImageMaxScale = 10.0;
static CGFloat const ImageMinScale = 1;

@interface ImagePreview ()
{
    BOOL downloading;
    CGFloat scale;
    CGRect orginalRect;

}

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation ImagePreview

+ (instancetype)showInView:(UIView*)view{
    ImagePreview *preview = [[ImagePreview alloc]initWithFrame:view.bounds];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [view addSubview:preview];
    return preview;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        downloading = NO;
        scale = 1;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addGestureRecognizer:self.tapGesture];
        [self addGestureRecognizer:self.pinchGesture];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}


- (void)setImage:(UIImage *)image{
    _image = image;
    [self fitImageViewWithImage:image];

}

- (void)setImageURL:(NSString *)imageURL{
    _imageURL = imageURL;
    [self.hud showAnimated:YES];
    downloading = YES;

    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        self.hud.progress = receivedSize * 1.0 / expectedSize;

    }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [self.hud hideAnimated:YES];
        [self fitImageViewWithImage:image];
        downloading = NO;
    }];
}

- (void)fitImageViewWithImage:(UIImage *)image{
    
    self.imageView.image = image;
    orginalRect = self.imageView.frame;
    self.imageView.center = CGPointMake(self.scrollView.dk_w/2, self.scrollView.dk_h/2);
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer{

    //图片还在下载 ..
    if (downloading) {
        return;
    }
    
    scale = recognizer.scale;
    if (scale<ImageMinScale) {
        scale = ImageMinScale;
    }
    if (scale>ImageMaxScale) {
        scale = ImageMaxScale;
    }
    
    if([recognizer state] == UIGestureRecognizerStateEnded && scale < 1) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.scrollView.contentSize = orginalRect.size;
            self.imageView.frame = orginalRect;
        }];
        
        return;
    }
    
    self.imageView.frame = CGRectMake(0, 0, orginalRect.size.width * scale, orginalRect.size.height * scale);
    self.scrollView.contentH = self.imageView.dk_h;
    self.scrollView.contentW = self.imageView.dk_w;
    self.scrollView.contentOffset = CGPointMake(self.imageView.dk_w /2 - self.scrollView.dk_w/2, self.imageView.dk_h /2 - self.scrollView.dk_h /2);

}


- (void)handleTap{
    [self removeFromSuperview];
    [[SDWebImageDownloader sharedDownloader]cancelAllDownloads];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (UIPinchGestureRecognizer *)pinchGesture{
    if (_pinchGesture) {
        return _pinchGesture;
    }
    _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    return _pinchGesture;
}

- (UITapGestureRecognizer *)tapGesture{
    if (_tapGesture) {
        return _tapGesture;
    }
    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
    return _tapGesture;
}


- (MBProgressHUD *)hud{
    if (_hud) {
        return _hud;
    }
    _hud = [[MBProgressHUD alloc]initWithView:self];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    return _hud;
}

- (UIImageView *)imageView{
    if (_imageView) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc]initWithFrame:self.scrollView.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    return _imageView;
}

- (UIScrollView *)scrollView{
    if (_scrollView) {
        return _scrollView;
    }
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.bouncesZoom = YES;
    _scrollView.bounces = YES;
    return _scrollView;
}

@end
