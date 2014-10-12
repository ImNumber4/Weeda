//
//  WLProgressView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/11/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLProgressView.h"

@implementation WLProgressView

@synthesize trackImage;
@synthesize progressImage;
@synthesize progress;
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        CALayer *l = self.layer;
        [l setMasksToBounds:YES];
        [l setCornerRadius:20.0];
        
        _trackImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _progressImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, frame.size.width, 0.0)];

        _trackImageView.contentMode = UIViewContentModeScaleToFill;
        _progressImageView.contentMode = UIViewContentModeBottom;
        _progressImageView.clipsToBounds = YES;
        
        [self addSubview:_trackImageView];
        [self addSubview:_progressImageView];
        [self bringSubviewToFront:_progressImageView];
    }
    
    return self;
}

- (void)setTrackImage:(UIImage *)image
{
    trackImage = image;
    _trackImageView.image = image;
}

- (void)setProgressImage:(UIImage *)image
{
    progressImage = image;
    _progressImageView.image = image;
}

- (void)setProgress:(CGFloat)theProgress
{
    CGFloat height = theProgress * self.frame.size.height;
    _progressImageView.hidden = NO;
    
    [UIView animateWithDuration:1 animations:^{
        [_progressImageView setFrame:CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height)];
    }];
    
    NSLog(@"Progress %f, frame: %f --  %f -- %f -- %f", theProgress, _progressImageView.frame.origin.x, _progressImageView.frame.origin.y, _progressImageView.frame.size.width, _progressImageView.frame.size.height);
}

- (void)lvLovesPz:(CGFloat)loveProgress
{
    CGFloat height = loveProgress * self.frame.size.height;
    _progressImageView.hidden = NO;
    
    [UIView animateWithDuration:1 animations:^{
        [_progressImageView setFrame:CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height)];
    }];
    
    NSLog(@"Progress %f, frame: %f --  %f -- %f -- %f", loveProgress, _progressImageView.frame.origin.x, _progressImageView.frame.origin.y, _progressImageView.frame.size.width, _progressImageView.frame.size.height);

}

- (void)createTestUIView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    imageView.image = [UIImage imageNamed:@"selected_weed.png"];
    [self addSubview:imageView];
    [self bringSubviewToFront:imageView];
}

@end