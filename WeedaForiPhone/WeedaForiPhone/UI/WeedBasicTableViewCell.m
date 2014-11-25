//
//  WeedBasicTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedBasicTableViewCell.h"
#import "WeedImageController.h"
#import "UIViewHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation WeedBasicTableViewCell

static double PADDING = 10;
static double AVATAR_SIZE = 40;
static double TIME_LABEL_WIDTH = 70;
static double STORE_TYPE_ICON_SIZE = 15;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.userAvatar = [[WLImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING/2.0, AVATAR_SIZE, AVATAR_SIZE)];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.userInteractionEnabled = true;
        self.userAvatar.clipsToBounds = YES;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        self.userAvatar.userInteractionEnabled = YES;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped)]];
        [self addSubview:self.userAvatar];
        
        self.storeTypeIcon = [[UserIcon alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width - STORE_TYPE_ICON_SIZE/2.0, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height - STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE)];
        [self addSubview:self.storeTypeIcon];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING, self.userAvatar.frame.origin.y, 50, self.userAvatar.frame.size.height/2.0)];
        self.usernameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.usernameLabel setTextColor:[UIColor blackColor]];
        [self.usernameLabel setFont:[UIFont systemFontOfSize:12]];
        self.usernameLabel.userInteractionEnabled = true;
        [self.usernameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped)]];
        [self addSubview:self.usernameLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - TIME_LABEL_WIDTH, self.userAvatar.frame.origin.y, TIME_LABEL_WIDTH, AVATAR_SIZE/2.0)];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.timeLabel setFont:[UIFont systemFontOfSize:10.0]];
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

- (void)decorateCellWithContent:(NSString *)content username:(NSString *) username time:(NSDate *) time user_id:(id) user_id user_type:(NSString *) user_type
{
    self.weedContentLabel.text = [NSString stringWithFormat:@"%@", content];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
    [self.usernameLabel setText:nameLabel];
    double maxWidth = self.frame.size.width - PADDING * 4 - AVATAR_SIZE - TIME_LABEL_WIDTH;
    CGSize size = [self.usernameLabel sizeThatFits:CGSizeMake(maxWidth, AVATAR_SIZE/2.0)];
    [self.usernameLabel setFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y, MIN(size.width, maxWidth), AVATAR_SIZE/2.0)];
    
    self.timeLabel.text = self.timeLabel.text = [UIViewHelper formatTime:time];;
    
    [self.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    
    [self.storeTypeIcon setUserType:user_type];
}

+ (CGFloat)getCellHeight
{
    return 50.0f;
}

-(void)userAvatarTapped {
    [self showUser:self];
}

-(void)showUser:(id) sender {        
    if ([self.delegate respondsToSelector:@selector(showUser:)]) {
        [self.delegate showUser:self];
    }
}

@end
