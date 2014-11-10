//
//  AppDelegate.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationDelegate <NSObject>
@required
- (void) updateBadgeCount:(NSInteger) badgeCount;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#define ROOT_URL @"http://www.cannablaze.com/"

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) User * currentUser;
@property NSInteger badgeCount;
@property (nonatomic, weak) id<NotificationDelegate> notificationDelegate;

- (void) decreaseBadgeCount:(NSInteger) decreaseBy;
- (void) updateBadgeCount;
- (void) populateCurrentUserFromCookie;
- (void) clearLoginCookies;
- (void)signoutFrom:(UIViewController *) sender;

@end
