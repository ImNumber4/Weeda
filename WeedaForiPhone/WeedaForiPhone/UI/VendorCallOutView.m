//
//  VendorCallOutView.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/29/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "VendorCallOutView.h"

@interface VendorCallOutView ()

@end

@implementation VendorCallOutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"VendorCallOutView" owner:self options:nil];
        self.bounds = self.view.bounds;
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"VendorCallOutView" owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
}

@end
