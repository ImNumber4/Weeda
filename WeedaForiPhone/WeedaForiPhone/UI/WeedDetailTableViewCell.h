//
//  WeedDetailTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeedDetailTableViewCell : UITableViewCell {
    UIView *_board;
}

@property (weak, nonatomic) IBOutlet UILabel *weedContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;

- (void)decorateCellWithWeed:(Weed *)weed;

@end
