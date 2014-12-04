//
//  WeedDetailTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLImageView.h"
#import "FollowButton.h"
#import "UserIcon.h"

@class WeedDetailTableViewCell;
@protocol WeedDetailTableViewCellDelegate <NSObject>
@required
- (void)showUserViewController:(id)sender;
- (void)tableViewCell:(WeedDetailTableViewCell *)cell height:(CGFloat)height needReload:(BOOL)needReload;
- (void)selectWeedContent:(UIGestureRecognizer *)recognizer;
@optional
- (void)didFinishDeleteCell;
@end

@interface WeedDetailTableViewCell : UITableViewCell {
    UIView *_board;
}

@property (nonatomic, retain) id<WeedDetailTableViewCellDelegate> delegate;

@property (strong, nonatomic) UITextView *weedContentLabel;
@property (strong, nonatomic) UIButton *userLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) WLImageView *userAvatar;
@property (strong, nonatomic) FollowButton * followButton;
@property (strong, nonatomic) UserIcon * userIcon;

@property (nonatomic, retain) Weed *weed;

- (void)decorateCellWithWeed:(Weed *)weed parentViewController:(UIViewController *) parentViewController showHeader:(BOOL) showHeader;
- (void)cellWillDisappear;
/*
 * this method should only be used when you already displayed the cell once, and you just want refresh control data to avoid additional refresh for other subviews
 */
- (void) refreshControlDataWithWeed:(Weed *) weed;
+ (CGFloat)heightForCell:(Weed*) weed showHeader:(BOOL) showHeader;

@end
