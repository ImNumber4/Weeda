//
//  WeedShowImageCell.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 6/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedShowImageCell.h"

@implementation WeedShowImageCell

- (void)awakeFromNib
{
    // Initialization code
    [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    NSLog(@"cell imageview size, width: %f, height: %f.", self.frame.size.width, self.frame.size.height);
}

@end
