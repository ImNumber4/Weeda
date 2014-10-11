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

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) User * currentUser;
@property NSInteger badgeCount;
@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, weak) id<NotificationDelegate> notificationDelegate;

- (void) decreaseBadgeCount:(NSInteger) decreaseBy;
- (void) updateBadgeCount;

@end
