//
//  WeedImageMaxDisplayView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedImageMaxDisplayView.h"
#import "WeedImageController.h"
#import "WLProgressView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface WeedImageMaxDisplayView() <UIGestureRecognizerDelegate> {
//    WLProgressView *_progress;
//    UIProgressView *_progress;
    CGFloat _lastRotation;
}

@end

@implementation WeedImageMaxDisplayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _backgroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.0;
        [self addSubview:_backgroundView];
        
        _originalImageView = imageView;
        
        _imageView = [[UIImageView alloc]initWithFrame:[self originalImageViewRect]];
        _imageView.image = imageView.image;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
//        _progress = [[WLProgressView alloc]initWithFrame:CGRectMake((self.frame.size.width - 40) * 0.5f, (self.frame.size.height - 40) * 0.5f, 40, 40)];
//        [_progress setTrackImage:[WeedImageController imageWithImage:[UIImage imageNamed:@"weed.png"] scaledToSize:CGSizeMake(40, 40)]];
//        [_progress setProgressImage:[WeedImageController imageWithImage:[UIImage imageNamed:@"weed.png"] scaledToSize:CGSizeMake(40, 40)]];

//        _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 2)];
//        [_progress setTrackTintColor:[ColorDefinition grayColor]];
//        [_progress setProgressTintColor:[ColorDefinition greenColor]];

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]];
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotation:)];
        [rotationGesture setDelegate:self];
        [self addGestureRecognizer:rotationGesture];
        
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (CGRect)originalImageViewRect
{
    CGPoint position = [[UIApplication sharedApplication].windows.lastObject convertPoint:CGPointMake(0, 0) fromView:_originalImageView];
    return  CGRectMake(position.x, position.y, _originalImageView.bounds.size.width, _originalImageView.bounds.size.height);
}

- (CGRect)imageFrame
{
    CGSize size = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    CGFloat ratio = fminf(size.height / imageSize.height, size.width / imageSize.width);
    
    CGFloat width = imageSize.width * ratio;
    CGFloat heigth = imageSize.height * ratio;
    
    return CGRectMake(self.bounds.origin.x, (self.bounds.size.height - heigth) / 2, width, heigth);
}

- (void)display:(UIImageView *)imageView
{
    [self display:imageView imageURL:nil];
}

- (void)display:(UIImageView *)imageView imageURL:(NSURL *)imageURL
{
    self.frame = [[UIApplication sharedApplication].windows.lastObject frame];
    _backgroundView.frame = [[UIApplication sharedApplication].windows.lastObject frame];
    
    _originalImageView = imageView;
    _imageView.frame = [self originalImageViewRect];
    _imageView.image = imageView.image;
    
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = [self imageFrame];
        [_backgroundView setAlpha:0.9];
    } completion:^(BOOL finished) {
        if (imageURL && finished) {
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [indicatorView setFrame:CGRectMake((self.frame.size.width - 40) / 2, (self.frame.size.height - 40) / 2, 40, 40)];
            [indicatorView isAnimating];
            [self addSubview:indicatorView];
            [self bringSubviewToFront:indicatorView];
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:(SDWebImageHandleCookies | SDWebImageCacheMemoryOnly) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                NSLog(@"received size %ld expected size %ld", receivedSize, expectedSize);
                if (expectedSize == -1) {
                    [indicatorView startAnimating];
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image && finished) {
                    _imageView.image = image;
                } else {
                    NSLog(@"Max Image View loading Image failed. image url: %@, error: %@", imageURL, error);
                }
                [indicatorView stopAnimating];
                [indicatorView removeFromSuperview];
            }];
        }
    }];
//        if (imageURL && finished) {
//            [self addSubview:_progress];
//            [self bringSubviewToFront:_progress];
//            
//            [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:(SDWebImageHandleCookies | SDWebImageCacheMemoryOnly)
//            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                NSLog(@"received size %ld expected size %ld", receivedSize, expectedSize);
//                if (expectedSize > 0) {
//                    [self updateProgress:(float)receivedSize / (float)expectedSize];
//                }
//            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                if (image && finished) {
//                    _imageView.image = image;
//                } else {
//                    NSLog(@"Loading Image failed. image url: %@, error: %@", imageURL, error);
//                }
//                [_progress removeFromSuperview];
//            }];
//        }
//    }];
    
}

//- (void)updateProgress:(CGFloat)progress
//{
//    NSLog(@"Progress: %f", progress);
//    [_progress setProgress:progress];
//}

#pragma Gesture recognizers

- (void)handleTap:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = [self originalImageViewRect];
        [_backgroundView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)handleRotation:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (_lastRotation - ((UIRotationGestureRecognizer *)gesture).rotation);
    
    CGAffineTransform currentTransform = _imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    
    [_imageView setTransform:newTransform];
    
    _lastRotation = ((UIRotationGestureRecognizer *)gesture).rotation;
}



@end
