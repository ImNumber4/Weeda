//
//  DetailViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Weed *weed;
@property (weak, nonatomic) IBOutlet UILabel *weedContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIButton *waterCount;
@property (weak, nonatomic) IBOutlet UIButton *seedCount;
@end
