//
//  WeedImageMaxDisplayView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLImageView.h"

@interface WeedImageMaxDisplayView : UIView {
    UIImageView *_originalImageView;
    WLImageView *_imageView;
    
    UIView *_backgroundView;
}

@property (nonatomic) BOOL changeAlphaValueDuringAnimation;
@property (nonatomic) BOOL shouldDownloadForFullScreenDisplay;

- (id)initWithImageView:(UIImageView *)imageView;
- (void)display:(UIImageView *)imageView;

@end
