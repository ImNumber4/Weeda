//
//  WeedTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeedTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource> {
    int _imageCount;
    Weed *_weedTmp;
}

@property (nonatomic, weak) IBOutlet UIButton *usernameLabel;
@property (nonatomic, weak) IBOutlet UITextView *weedContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userAvatar;
@property (nonatomic, weak) IBOutlet UIButton *seed;
@property (nonatomic, weak) IBOutlet UILabel *seedCount;
@property (nonatomic, weak) IBOutlet UIButton *waterDrop;
@property (nonatomic, weak) IBOutlet UILabel *waterCount;
@property (nonatomic, weak) IBOutlet UIButton *light;
@property (nonatomic, weak) IBOutlet UILabel *lightCount;

@property (nonatomic, weak) IBOutlet UIView *view;

@property (nonatomic, retain) UICollectionView *imageCollectionView;

- (void)hideControls;
- (void)decorateCellWithWeed:(Weed *)weed;

@end
