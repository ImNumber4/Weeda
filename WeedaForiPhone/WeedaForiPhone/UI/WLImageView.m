//
//  WLImageView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLImageView.h"

@implementation WLImageView

@synthesize imageURL;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURL isMaxDisplay:(BOOL)isMaxDisplay
{
    self = [super initWithFrame:frame];
    if (isMaxDisplay) {
        _isMaxDisplay = YES;
        _maxDisplayView = [[WeedImageMaxDisplayView alloc]initWithImageView:self];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]];
    } else {
        _isMaxDisplay = NO;
    }
    
    return self;
}

- (void)turnOnMaxDisplay
{
    _isMaxDisplay = YES;
    
    if (!_maxDisplayView) {
        _maxDisplayView = [[WeedImageMaxDisplayView alloc]initWithImageView:self];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]];
    }
}

- (void)turnOffMaxDisplay
{
    _isMaxDisplay = NO;
}

- (void)handleTap:(UIGestureRecognizer *)gesture
{
    if (_maxDisplayView && _isMaxDisplay) {
        [self addSubview:_maxDisplayView];
        [(UIView *)[UIApplication sharedApplication].windows.lastObject addSubview:_maxDisplayView];
        [_maxDisplayView display:self imageURL:[self imageURL]];
    }
}

@end
