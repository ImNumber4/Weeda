//
//  WLProgressView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/11/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLProgressView : UIView {
    UIImageView *_trackImageView;
    UIImageView *_progressImageView;
}

@property (nonatomic, retain) UIImage *trackImage;
@property (nonatomic, retain) UIImage *progressImage;

@property (nonatomic) CGFloat progress;

@property (nonatomic) BOOL changeAlphaValueDuringAnimation;

- (void)setTrackImage:(UIImage *)image;
- (void)setProgressImage:(UIImage *)image;

- (void)setProgress:(CGFloat)progress;
- (void)lvLovesPz:(CGFloat)loveProgress;

- (void)createTestUIView;

@end
