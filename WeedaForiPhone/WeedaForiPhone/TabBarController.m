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

const NSInteger WEEDS_TAB_BAR_ITEM_INDEX = 0;
const NSInteger MESSAGES_TAB_BAR_ITEM_INDEX = 1;
const NSInteger DISCOVER_TAB_BAR_ITEM_INDEX = 2;
const NSInteger ME_TAB_BAR_ITEM_INDEX = 3;


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
    UITabBarItem *weedsTabBarItem = [tabBar.items objectAtIndex:WEEDS_TAB_BAR_ITEM_INDEX];
    UITabBarItem *messagesTabBarItem = [tabBar.items objectAtIndex:MESSAGES_TAB_BAR_ITEM_INDEX];
    UITabBarItem *discoverTabBarItem = [tabBar.items objectAtIndex:DISCOVER_TAB_BAR_ITEM_INDEX];
    UITabBarItem *meTabBarItem = [tabBar.items objectAtIndex:ME_TAB_BAR_ITEM_INDEX];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *userViewNav = [self.viewControllers objectAtIndex:3];
    UserViewController *userView = (UserViewController *)userViewNav.topViewController;
    [userView setUser_id:appDelegate.currentUser.id];
    
    weedsTabBarItem.title = @"Weeds";
    messagesTabBarItem.title = @"Messages";
    discoverTabBarItem.title = @"Discover";
    meTabBarItem.title = @"Me";
    
    
    weedsTabBarItem.selectedImage = [[self getImage:@"selected_weed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    weedsTabBarItem.image = [[self getImage:@"weed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    messagesTabBarItem.image = [[self getImage:@"message.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    messagesTabBarItem.selectedImage = [[self getImage:@"selected_message.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    discoverTabBarItem.image = [[self getImage:@"map.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    discoverTabBarItem.selectedImage = [[self getImage:@"selected_map.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    meTabBarItem.image = [[self getImage:@"profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    meTabBarItem.selectedImage = [[self getImage:@"selected_profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBar.tintColor = [ColorDefinition greenColor];

    appDelegate.notificationDelegate = self;
    [appDelegate updateBadgeCount];
}

- (void) updateBadgeCount:(NSInteger) badgeCount
{
    UITabBarItem *messageTabBarItem = [self.tabBar.items objectAtIndex:MESSAGES_TAB_BAR_ITEM_INDEX];
    if (badgeCount > 0) {
        if (badgeCount >= 1000000000) {
            [messageTabBarItem setBadgeValue:[NSString stringWithFormat:@"%ldB", (long)(badgeCount/1000000000.0)]];
        } else if (badgeCount >= 1000000) {
            [messageTabBarItem setBadgeValue:[NSString stringWithFormat:@"%ldM", (long)(badgeCount/1000000.0)]];
        } else if (badgeCount >= 1000) {
            [messageTabBarItem setBadgeValue:[NSString stringWithFormat:@"%ldK", (long)(badgeCount/1000.0)]];
        } else {
            [messageTabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld", badgeCount]];
        }
    } else {
        messageTabBarItem.badgeValue = nil;
    }
}

- (UIImage *)getImage:(NSString *)imageName
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(25, 25);
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
