//
//  TabBarController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/13/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "AppDelegate.h"
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
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [masterViewController setCurrentUser: appDelegate.currentUser];
    
    UserViewController *userView = [self.viewControllers objectAtIndex:1];
    [userView setCurrentUser:appDelegate.currentUser];
    [userView setUser_id:appDelegate.currentUser.id];
    
    tabBarItem1.title = @"Weeds";
    tabBarItem2.title = @"Me";
    
    
    tabBarItem1.selectedImage = [[self getImage:@"selected_weed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1.image = [[self getImage:@"weed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.image = [[self getImage:@"profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = [[self getImage:@"selected_profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBar.tintColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
}

- (UIImage *)getImage:(NSString *)imageName
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
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
