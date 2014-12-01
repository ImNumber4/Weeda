//
//  WeedTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLImageView.h"
#import "UserIcon.h"

#define MASTERVIEW_IMAGEVIEW_HEIGHT 200

@class WeedTableViewCell;
@protocol WeedTableViewCellDelegate <NSObject>
@required
- (void)showUserViewController:(id)sender;
- (void)selectWeedContent:(UIGestureRecognizer *)recognizer;
@optional
- (BOOL)pressURL:(NSURL *)url;
- (void)didFinishDeleteCell;
@end

@interface WeedTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource> {
    int _imageCount;
    Weed *_weedTmp;
    UIViewController *_parentViewController;
}
@property (nonatomic, retain) id<WeedTableViewCellDelegate> delegate;

@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UITextView *weedContentLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *seededByLabel;
@property (nonatomic, retain) WLImageView *userAvatar;
@property (nonatomic, strong) UserIcon *storeTypeIcon;

- (void)decorateCellWithWeed:(Weed *)weed parentViewController:(UIViewController *)parentViewController;

+ (CGFloat)heightOfWeedTableViewCell:(Weed *)weed width:(double)width;

@end
