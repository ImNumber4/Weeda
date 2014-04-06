//
//  UserViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) User * currentUser;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
