//
//  WLAddWeedPhotoImageView.m
//  WeedaForiPhone
//
//  Created by Wu Tony on 6/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedAddingImageView.h"

@implementation WeedAddingImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:(UIControlStateNormal)];
        [deleteButton addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.frame = CGRectMake(frame.size.width - 20, 5, 15, 15);
        deleteButton.contentMode = UIViewContentModeScaleAspectFit;
        
        deleteButton.userInteractionEnabled = YES;
        deleteButton.alpha = 0.7f;
        
        self.userInteractionEnabled = YES;
        [self addSubview:deleteButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return [self initWithFrame:self.frame];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)deletePhoto:(id)sender
{
//    [self removeFromSuperview];
    if (self.delegate) {
        [self.delegate pressDelete:self];
    } else {
        NSLog(@"Don't have delegate!");
    }
}

@end
