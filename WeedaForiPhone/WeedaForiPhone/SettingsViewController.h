//
//  SettingsViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/22/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

+ (UIColor *) settingViewBackgroundColor;
+ (void) decorateSettingViewStyleTableCell:(UITableViewCell *) cell;
+ (void) decorateSettingViewStyleTable:(UITableView *) tableView;

@end
