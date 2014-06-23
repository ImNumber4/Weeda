//
//  WeedTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedTableViewCell.h"

@implementation WeedTableViewCell

- (void)awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"WeedTableViewCell" owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hideControls
{
    self.light.hidden = true;
    self.lightCount.hidden = true;
    self.seed.hidden = true;
    self.seedCount.hidden = true;
    self.waterDrop.hidden = true;
    self.waterCount.hidden = true;
}

- (void)decorateCellWithWeed:(Weed *)weed
{
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    self.weedContentLabel.text = weed.content;
    [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, self.weedContentLabel.contentSize.height)];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", weed.username];
    [self.usernameLabel setTitle:nameLabel forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    
    if ([weed.if_cur_user_water_it intValue] == 1) {
        [self.waterDrop setImage:[UIImage imageNamed:@"waterdrop.png"] forState:UIControlStateNormal];
    } else {
        [self.waterDrop setImage:[UIImage imageNamed:@"waterdropgray.png"] forState:UIControlStateNormal];
    }
    if ([weed.if_cur_user_seed_it intValue] == 1) {
        [self.seed setImage:[UIImage imageNamed:@"seed.png"] forState:UIControlStateNormal];
    } else {
        [self.seed setImage:[UIImage imageNamed:@"seedgray.png"] forState:UIControlStateNormal];
    }
    if ([weed.if_cur_user_light_it intValue] == 1) {
        [self.light setImage:[UIImage imageNamed:@"light.png"] forState:UIControlStateNormal];
    } else {
        [self.light setImage:[UIImage imageNamed:@"lightgray.png"] forState:UIControlStateNormal];
    }
    self.lightCount.text = [NSString stringWithFormat:@"%@", weed.light_count];
    self.seedCount.text = [NSString stringWithFormat:@"%@", weed.seed_count];
    self.waterCount.text = [NSString stringWithFormat:@"%@", weed.water_count];
}

@end
