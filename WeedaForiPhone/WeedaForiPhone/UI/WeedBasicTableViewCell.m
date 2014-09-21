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
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped)];
    [self.userAvatar addGestureRecognizer:singleTap];
    self.userAvatar.userInteractionEnabled = YES;
    [self.usernameLabel addTarget:self action:@selector(showUser:)forControlEvents:UIControlEventTouchDown];
}

- (void)decorateCellWithWeed:(NSString *)content username:(NSString *) username time:(NSDate *) time user_id:(id) user_id
{
    self.weedContentLabel.text = [NSString stringWithFormat:@"%@", content];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
    [self.usernameLabel setTitle:nameLabel forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    
    [self.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

-(void)userAvatarTapped {
    [self showUser:self];
}

-(void)showUser:(id) sender {
    [self.delegate showUser:self];
}

@end
