//
//  WeedTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLImageView.h"

#define MASTERVIEW_IMAGEVIEW_HEIGHT 200

@class WeedTableViewCell;
@protocol WeedTableViewCellDelegate <NSObject>
@required
- (void)showUserViewController:(id)sender;
- (void)selectWeedContent:(UIGestureRecognizer *)recognizer;
@optional
- (BOOL)pressURL:(NSURL *)url;
@end

@interface WeedTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource> {
    int _imageCount;
    Weed *_weedTmp;
}
@property (nonatomic, retain) id<WeedTableViewCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *usernameLabel;
@property (nonatomic, weak) IBOutlet UITextView *weedContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet WLImageView *userAvatar;
@property (nonatomic, weak) IBOutlet UIButton *seed;
@property (nonatomic, weak) IBOutlet UILabel *seedCount;
@property (nonatomic, weak) IBOutlet UIButton *waterDrop;
@property (nonatomic, weak) IBOutlet UILabel *waterCount;
@property (nonatomic, weak) IBOutlet UIButton *light;
@property (nonatomic, weak) IBOutlet UILabel *lightCount;

@property (nonatomic, weak) IBOutlet UIView *view;

- (void)hideControls;
- (void)decorateCellWithWeed:(Weed *)weed;

+ (CGFloat)heightOfWeedTableViewCell:(Weed *)weed;

@end
