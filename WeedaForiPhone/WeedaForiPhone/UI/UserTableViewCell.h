//
//  UserTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/20/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLUIImageView.h"

#define USER_TABLE_VIEW_CELL_HEIGHT 50;

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *userAvatar;
@property (nonatomic, strong) UIImageView *storeTypeIcon;

- (void)decorateCellWithUser:(User *)user;

@end
