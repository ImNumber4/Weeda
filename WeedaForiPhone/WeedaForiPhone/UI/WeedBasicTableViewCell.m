//
//  WeedBasicTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedBasicTableViewCell.h"
#import "WeedImageController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation WeedBasicTableViewCell

- (void)awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"WeedBasicTableViewCell" owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)decorateCellWithWeed:(Weed *)weed
{
    self.weedContentLabel.text = [NSString stringWithFormat:@"%@", weed.content];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", weed.username];
    [self.usernameLabel setTitle:nameLabel forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    
    [self.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:weed.user_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

@end
