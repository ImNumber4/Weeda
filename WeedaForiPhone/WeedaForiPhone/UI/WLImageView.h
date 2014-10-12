//
//  WLImageView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeedImageMaxDisplayView.h"

@interface WLImageView : UIImageView {
    WeedImageMaxDisplayView *_maxDisplayView;
    BOOL _isMaxDisplay;
}

//- (id)initWithFrame:(CGRect)frame imageId:(NSString *)imageId isMaxDisplay:(BOOL)isMaxDisplay;
- (void)turnOnMaxDisplay;
//- (void)turnOffMaxDisplay;

@property (nonatomic, retain) NSURL *imageURL;

@end
