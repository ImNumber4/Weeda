//
//  EditProfileViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoEditableCell.h"

@interface EditProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,  UserInfoEditableCellDelegate>

@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) User * userObject;

@end
