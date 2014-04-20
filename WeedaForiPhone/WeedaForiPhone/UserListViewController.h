//
//  UserListViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListViewController : UITableViewController  <NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) NSNumber * water_weed_id;
@property (strong) NSArray *users;
@end
