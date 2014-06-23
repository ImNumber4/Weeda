//
//  UserViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import <MapKit/MapKit.h>

@interface UserViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) NSNumber * user_id;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIButton *weedCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet MKMapView *location;

@property (strong) NSArray *users;

@end
