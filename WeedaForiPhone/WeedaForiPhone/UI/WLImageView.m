//
//  WLImageView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLImageView.h"
#import "WLImageCollectionView.h"
#import "WeedImageMaxDisplayView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface WLImageView()

@property (nonatomic, retain) WeedImageMaxDisplayView *maxDisplayView;

@end

@implementation WLImageView

@synthesize dataSource;
@synthesize indexPath;
@synthesize allowCollectionViewDisplay;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame imageURL:(NSURL *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self sd_setImageWithURL:url placeholderImage:nil options:SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            ;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            ;
        }];
        
        _allowFullScreenDisplay = NO;
    }
    
    return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    [self sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        ;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        ;
    }];
}

- (void)setImageURL:(NSURL *)imageURL animate:(BOOL)animate
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView setFrame:CGRectMake((self.frame.size.width - 40) / 2, (self.frame.size.height - 40) / 2, 40, 40)];
    [indicatorView isAnimating];
    [self addSubview:indicatorView];
    [self bringSubviewToFront:indicatorView];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:(SDWebImageHandleCookies | SDWebImageCacheMemoryOnly)
    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (expectedSize == -1) {
            [indicatorView startAnimating];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image && finished) {
            self.image = image;
        } else {
            NSLog(@"Max Image View loading Image failed. image url: %@, error: %@", imageURL, error);
        }
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    }];
}

- (void)setAllowFullScreenDisplay:(BOOL)allowFullScreenDisplay
{
    _allowFullScreenDisplay = allowFullScreenDisplay;
    if (_allowFullScreenDisplay) {
        _maxDisplayView = [[WeedImageMaxDisplayView alloc]initWithImageView:self];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]];
    } else {
        _maxDisplayView = nil;
        self.userInteractionEnabled = NO;
    }
}

- (void)handleTap:(UIGestureRecognizer *)gesture
{
    if (_allowFullScreenDisplay) {
        [(UIView *)[UIApplication sharedApplication].windows.lastObject addSubview:_maxDisplayView];
        [_maxDisplayView display:self];
    }
}

@end
