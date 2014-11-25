//
//  WeedBasicTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLImageView.h"

@protocol WeedBasicTableViewCellDelegate <NSObject>
@required
- (void) showUser:(id) sender;
@end

@interface WeedBasicTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *weedContentLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) WLImageView *userAvatar;
@property (nonatomic, weak)id<WeedBasicTableViewCellDelegate> delegate;

- (void)decorateCellWithContent:(NSString *)content username:(NSString *) username time:(NSDate *) time user_id:(id) user_id;

+ (CGFloat)getCellHeight;

@end
