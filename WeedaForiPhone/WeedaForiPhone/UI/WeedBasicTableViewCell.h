//
//  WeedBasicTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeedBasicTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *weedContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userAvatar;

@property (nonatomic, weak) IBOutlet UIView *view;

- (void)decorateCellWithWeed:(Weed *)weed;

@end
