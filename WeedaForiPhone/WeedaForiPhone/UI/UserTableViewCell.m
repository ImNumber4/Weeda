//
//  UserTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/20/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserTableViewCell.h"
#import "WeedImageController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserTableViewCell()
@property (nonatomic, retain) User *user;
@end

@implementation UserTableViewCell

const double LEFT_PADDING = 10;
const double UI_PADDING = 5;
const double AVATAR_SIZE = 40;
const double LABEL_HEIGHT = AVATAR_SIZE/2.0;
const double STORE_TYPE_ICON_SIZE = 15;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews = YES;
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING, UI_PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        [self addSubview:self.userAvatar];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.clipsToBounds = YES;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:AVATAR_SIZE/2.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        double labelX = LEFT_PADDING + self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + UI_PADDING;
        
        double followButtonWidth = FOLLOW_BUTTON_WIDTH;
        double followButtonHeight = FOLLOW_BUTTON_HEIGHT;
        
        double labelWidth = self.frame.size.width - UI_PADDING * 2 - followButtonWidth - labelX;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, self.userAvatar.frame.origin.y, labelWidth, LABEL_HEIGHT)];
        [self.usernameLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:self.usernameLabel];
        
        self.storeTypeIcon = [[UserIcon alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width - STORE_TYPE_ICON_SIZE/2.0, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height - STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE)];
        [self addSubview:self.storeTypeIcon];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, self.userAvatar.frame.origin.y + LABEL_HEIGHT, labelWidth, LABEL_HEIGHT)];
        [self.addressLabel setFont:[UIFont systemFontOfSize:11]];
        [self.addressLabel setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.addressLabel];
        
        self.followButton = [[FollowButton alloc] initWithFrame:CGRectMake(UI_PADDING + self.usernameLabel.frame.origin.x + self.usernameLabel.frame.size.width, self.userAvatar.center.y - followButtonHeight/2.0, followButtonWidth, followButtonHeight)];
        self.followButton.tintColor = [UIColor whiteColor];
        [self addSubview:self.followButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)decorateCellWithUser:(User *)user {
    NSString * address = [user getSimpleFormatedAddress];
    if (!address || [address isEqualToString:@""]) {
        address = user.userDescription;
    } else {
        address = [NSString stringWithFormat:@"From %@", address];
    }
    [self decorateCellWithUser:user subtitle:address];
}

- (void)decorateCellWithUser:(User *)user subtitle:(NSString*) subtitle {
    self.user = user;
    [self.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user.id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    NSString *nameLabel;
    if ([USER_TYPE_USER isEqualToString:user.user_type] || !user.storename) {
        nameLabel = [NSString stringWithFormat:@"@%@", user.username];
    } else {
        nameLabel = [NSString stringWithFormat:@"@%@ (%@)", user.username, user.storename];
    }
    self.usernameLabel.text = nameLabel;
    self.addressLabel.text = subtitle;
    [self.storeTypeIcon setUserType:user.user_type];
    
    if (user.relationshipWithCurrentUser) {
        self.followButton.hidden = false;
    } else {
        self.followButton.hidden = true;
    }
    double labelX = self.usernameLabel.frame.origin.x;
    
    double labelWidth;
    if (user.relationshipWithCurrentUser) {
        double followButtonWidth = FOLLOW_BUTTON_WIDTH;
        labelWidth = self.frame.size.width - UI_PADDING * 2 - followButtonWidth - labelX;
    } else {
        labelWidth = self.frame.size.width - labelX - UI_PADDING;
    }
    [self.addressLabel setFrame:CGRectMake(self.addressLabel.frame.origin.x, self.addressLabel.frame.origin.y, labelWidth, self.addressLabel.frame.size.height)];
    
    if (!subtitle || [subtitle isEqualToString:@""]) {
        [self.usernameLabel setFrame:CGRectMake(labelX, self.userAvatar.center.y - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT)];
        self.addressLabel.hidden = true;
    } else {
        [self.usernameLabel setFrame:CGRectMake(labelX, self.userAvatar.frame.origin.y, labelWidth, LABEL_HEIGHT)];
        self.addressLabel.hidden = false;
    }
    
    [self.followButton setUser_id:user.id relationshipWithCurrentUser:user.relationshipWithCurrentUser];
}



@end
