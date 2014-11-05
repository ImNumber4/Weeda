//
//  WeedDetailTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLImageView.h"

@class WeedDetailTableViewCell;
@protocol WeedDetailTableViewCellDelegate <NSObject>
@required
- (void)showUserViewController:(id)sender;
@end

@interface WeedDetailTableViewCell : UITableViewCell {
    UIView *_board;
}

@property (nonatomic, retain) id<WeedDetailTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *weedContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet WLImageView *userAvatar;

- (void)decorateCellWithWeed:(Weed *)weed;

@end
