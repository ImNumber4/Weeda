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
const double FOLLOW_BUTTON_HEIGHT = 20;
const double FOLLOW_BUTTION_WIDTH = 40;
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
        [l setCornerRadius:7.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        double labelX = LEFT_PADDING + self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width;
        double labelWidth = self.frame.size.width - UI_PADDING * 2 - FOLLOW_BUTTION_WIDTH - labelX;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX + STORE_TYPE_ICON_SIZE + UI_PADDING, self.userAvatar.frame.origin.y, labelWidth - (STORE_TYPE_ICON_SIZE + UI_PADDING), LABEL_HEIGHT)];
        [self.usernameLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:self.usernameLabel];
        
        self.storeTypeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(labelX, self.usernameLabel.center.y - STORE_TYPE_ICON_SIZE/2.0, STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE)];
        [self addSubview:self.storeTypeIcon];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, self.userAvatar.frame.origin.y + LABEL_HEIGHT, labelWidth, LABEL_HEIGHT)];
        [self.addressLabel setFont:[UIFont systemFontOfSize:11]];
        [self.addressLabel setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.addressLabel];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.followButton setFrame:CGRectMake(UI_PADDING + self.usernameLabel.frame.origin.x + self.usernameLabel.frame.size.width, self.userAvatar.center.y - FOLLOW_BUTTON_HEIGHT/2.0, FOLLOW_BUTTION_WIDTH, FOLLOW_BUTTON_HEIGHT)];
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
    [self decorateCellWithUser:user subtitle:[user getSimpleFormatedAddress]];
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
    UIImage * userIcon = [user getUserIcon];
    if (userIcon) {
        self.storeTypeIcon.image = userIcon;
        self.storeTypeIcon.hidden = false;
    } else {
        self.storeTypeIcon.hidden = true;
    }
    
    if (user.relationshipWithCurrentUser) {
        self.followButton.hidden = false;
    } else {
        self.followButton.hidden = true;
    }
    double labelX;
        labelX = LEFT_PADDING + self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + STORE_TYPE_ICON_SIZE + UI_PADDING;
    if (userIcon) {
    } else {
        labelX = LEFT_PADDING + self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width;
    }
    
    double labelWidth;
    if (user.relationshipWithCurrentUser) {
        labelWidth = self.frame.size.width - UI_PADDING * 2 - FOLLOW_BUTTION_WIDTH - labelX;
    } else {
        labelWidth = self.frame.size.width - labelX - UI_PADDING;
    }
    [self.addressLabel setFrame:CGRectMake(self.addressLabel.frame.origin.x, self.addressLabel.frame.origin.y, labelWidth, self.addressLabel.frame.size.height)];
    
    if ([USER_TYPE_USER isEqualToString:user.user_type] || !subtitle || [subtitle isEqualToString:@""]) {
        [self.usernameLabel setFrame:CGRectMake(labelX, self.userAvatar.center.y - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT)];
        self.addressLabel.hidden = true;
    } else {
        [self.usernameLabel setFrame:CGRectMake(labelX, self.userAvatar.frame.origin.y, labelWidth - (STORE_TYPE_ICON_SIZE + UI_PADDING), LABEL_HEIGHT)];
        self.addressLabel.hidden = false;
    }
    [self.storeTypeIcon setCenter:CGPointMake(self.storeTypeIcon.center.x, self.usernameLabel.center.y)];
    
    if (user.relationshipWithCurrentUser) {
        if ([user.relationshipWithCurrentUser intValue] == 0) {
            self.followButton.hidden = TRUE;
        } else if ([user.relationshipWithCurrentUser intValue] < 3){
            [self makeFollowButton:self.followButton];
            self.followButton.hidden = false;
        } else {
            [self makeFollowingButton:self.followButton];
            self.followButton.hidden = false;
        }
    } else {
        self.followButton.hidden = true;
    }
}

- (void)makeFollowButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    button.tintColor = [ColorDefinition blueColor];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"followed.png"] forState:UIControlStateNormal];
    //green
    button.tintColor = [ColorDefinition greenColor];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)follow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.user.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationshipWithCurrentUser;
        [self makeFollowingButton:self.followButton];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)unfollow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", self.user.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationshipWithCurrentUser;
        [self makeFollowButton:self.followButton];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

@end
