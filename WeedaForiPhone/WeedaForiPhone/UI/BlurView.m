//
//  BlurView.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 8/10/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "BlurView.h"

@implementation BlurView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        return;
    }
    UIGraphicsBeginImageContextWithOptions(newSuperview.bounds.size, YES, 0.0);
    [newSuperview drawViewHierarchyInRect:newSuperview.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[img applyBlurWithRadius:10
                                                                                        tintColor:[UIColor colorWithWhite:1 alpha:0.5]
                                                                            saturationDeltaFactor:1.8
                                                                                        maskImage:nil]];
    
    [self addSubview:imageView];
    [self sendSubviewToBack:imageView];
}

@end
