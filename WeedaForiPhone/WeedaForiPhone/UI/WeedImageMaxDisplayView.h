//
//  WeedImageMaxDisplayView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLProgressView.h"

@interface WeedImageMaxDisplayView : UIView {
    UIImageView *_originalImageView;
    UIImageView *_imageView;
    
    UIView *_backgroundView;
}

- (id)initWithImageView:(UIImageView *)imageView;
- (void)display:(UIImageView *)imageView;
- (void)display:(UIImageView *)imageView imageURL:(NSURL *)imageURL;

@end
