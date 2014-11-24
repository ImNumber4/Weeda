//
//  WeedBasicTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedBasicTableViewCell.h"
#import "WeedImageController.h"
#import "WLImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation WeedBasicTableViewCell

static double PADDING = 5;
static double AVATAR_SIZE = 40;
static double TIME_LABEL_WIDTH = 60;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.userInteractionEnabled = true;
        self.userAvatar.clipsToBounds = YES;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:7];
        self.userAvatar.userInteractionEnabled = YES;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped)]];
        [self addSubview:self.userAvatar];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING, PADDING, 50, self.userAvatar.frame.size.height/2.0)];
        self.usernameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.usernameLabel setTextColor:[UIColor blackColor]];
        [self.usernameLabel setFont:[UIFont systemFontOfSize:12]];
        self.usernameLabel.userInteractionEnabled = true;
        [self.usernameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped)]];
        [self addSubview:self.usernameLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - TIME_LABEL_WIDTH, PADDING, TIME_LABEL_WIDTH, AVATAR_SIZE/2.0)];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.timeLabel setFont:[UIFont systemFontOfSize:7.0]];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self addSubview:self.timeLabel];
        
        self.weedContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height, self.frame.size.width - PADDING - self.usernameLabel.frame.origin.x, self.userAvatar.frame.size.height/2.0)];
        [self.weedContentLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.weedContentLabel setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.weedContentLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)decorateCellWithContent:(NSString *)content username:(NSString *) username time:(NSDate *) time user_id:(id) user_id
{
    self.weedContentLabel.text = [NSString stringWithFormat:@"%@", content];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
    [self.usernameLabel setText:nameLabel];
    double maxWidth = self.frame.size.width - PADDING * 4 - AVATAR_SIZE - TIME_LABEL_WIDTH;
    CGSize size = [self.usernameLabel sizeThatFits:CGSizeMake(maxWidth, AVATAR_SIZE/2.0)];
    [self.usernameLabel setFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y, MIN(size.width, maxWidth), AVATAR_SIZE/2.0)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    
    [self.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
}

+ (CGFloat)getCellHeight
{
    return 50.0f;
}

-(void)userAvatarTapped {
    [self showUser:self];
}

-(void)showUser:(id) sender {
    if (self.delegate)
        [self.delegate showUser:self];
}

@end
