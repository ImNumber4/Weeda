//
//  MessageViewController.h
//  WeedaForiPhone
//
//  Created by LV on 9/4/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController

@property (retain, nonatomic) UITableView *tableView;
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
