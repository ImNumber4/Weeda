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
- (BOOL)pressURL:(NSURL *)url;
- (void)tableViewCell:(WeedDetailTableViewCell *)cell height:(CGFloat)height needReload:(BOOL)needReload;
@end

@interface WeedDetailTableViewCell : UITableViewCell {
    UIView *_board;
}

@property (nonatomic, retain) id<WeedDetailTableViewCellDelegate> delegate;

@property (strong, nonatomic) UITextView *weedContentLabel;
@property (strong, nonatomic) UIButton *userLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) WLImageView *userAvatar;

@property (nonatomic, retain) Weed *weed;

- (void)decorateCellWithWeed:(Weed *)weed parentViewController:(UIViewController *) parentViewController showHeader:(BOOL) showHeader;
- (void)cellWillDisappear;

@end
