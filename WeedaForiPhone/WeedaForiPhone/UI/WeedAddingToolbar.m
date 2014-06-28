//
//  WLAddWeedToolbar.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 6/15/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedAddingToolbar.h"

@implementation WeedAddingToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"WeedAddingToolbar" owner:self options:nil];
        self.bounds = self.view.bounds;
        [self addSubview:self.view];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"WeedAddingToolbar" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (IBAction)takePicturePress:(id)sender
{
    if (self.delegate) {
        [self.delegate pressTakingPicture:self];
    } else {
        NSLog(@"Don't have delegate!");
    }
}

- (IBAction)pickPicturePress:(id)sender
{
    if (self.delegate) {
        [self.delegate pressPickingPicture:self];
    } else {
        NSLog(@"Don't have delegate!");
    }
}
@end
