//
//  TabBarController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/13/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "TabBarController.h"
#import "MasterViewController.h"
#import "UserViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Assign tab bar item with titles
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    
    UINavigationController *nav = [self.viewControllers objectAtIndex:0];
    MasterViewController *masterViewController = (MasterViewController *)nav.topViewController;
    [masterViewController setCurrentUser:self.currentUser];
    
    UserViewController *userView = [self.viewControllers objectAtIndex:1];
    [userView setCurrentUser:self.currentUser];
    [userView setUser_id:self.currentUser.id];
    
    tabBarItem1.title = @"Weeds";
    tabBarItem2.title = @"Me";
    
    // this way, the icon gets rendered as it is (thus, it needs to be green in this example)
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"selected_weed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1.image = [[UIImage imageNamed:@"weed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem2.image = [[UIImage imageNamed:@"profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"selected_profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    /**
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"home_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home.png"]];
        [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"myplan_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"myplan.png"]];
    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"settings_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"settings.png"]];
    
    
    // Change the tab bar background
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
    */
    // Change the title color of tab bar items
    
    self.tabBar.tintColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
