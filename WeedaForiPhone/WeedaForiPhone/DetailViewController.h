//
//  DetailViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) id currentWeedId;
@property (strong, nonatomic) Weed *currentWeed;
@property (nonatomic, retain) NSMutableArray *parentWeeds;
@property (nonatomic, retain) NSMutableArray *lights;
@property (nonatomic, retain) NSMutableArray *weedImages;

@property (strong) NSArray *users;

@end
