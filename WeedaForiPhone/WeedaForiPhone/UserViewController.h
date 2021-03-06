//
//  UserViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MasterViewController.h"
#import "WLImageView.h"

@interface UserViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate>

@property (nonatomic, retain) NSNumber * user_id;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet WLImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarCamera;
@property (weak, nonatomic) IBOutlet UIButton *weedCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *userDescription;
@property (weak, nonatomic) IBOutlet MKMapView *location;

@end
