//
//  WelcomeViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-7.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "TabBarController.h"
#import "LoginViewController.h"
#import "MasterViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    //check cookie and renew the cookie expire time
    User *user = [self checkCookiesAndGetCurrentUser];
    if (!user) {
        sleep(2);
        [self performSegueWithIdentifier:@"login" sender:self];
    } else {
        //check cookie authentication
        //success, go to MasterView
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.currentUser = user;
        sleep(2);
        [self performSegueWithIdentifier:@"masterView" sender:self];
        
        //TODO: failure, go to LoginView
        
    }
}


#pragma mark - Navigation



- (User *) checkCookiesAndGetCurrentUser
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return nil;
    }
    
    //if there are more than one cookies, save the first one which not expired, delete others.
    NSHTTPCookie *userIdCookie = nil;
    NSHTTPCookie *usernameCookie = nil;
    NSHTTPCookie *passwordCookie = nil;
    NSArray *deleteCookie = nil;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"user_id"] && userIdCookie == nil) {
            userIdCookie = cookie;
            continue;
        }
        
        if ([cookie.name isEqualToString:@"username"] && usernameCookie == nil) {
            usernameCookie = cookie;
            continue;
        }
        
        if ([cookie.name isEqualToString:@"password"] && passwordCookie == nil) {
            passwordCookie = cookie;
            continue;
        }
        
        [deleteCookie arrayByAddingObject:cookie];
    }
    
    for (NSHTTPCookie *cookie in deleteCookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    if (userIdCookie == nil || usernameCookie == nil || passwordCookie == nil) {
        NSLog(@"There is no available cookie.");
        return nil;
    }
    
    if ([userIdCookie.expiresDate compare:[NSDate date]] == NSOrderedAscending) {
        NSLog(@"Cookie is expired.");
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:userIdCookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:usernameCookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:passwordCookie];
        return nil;
    }
    
    [self renewCookieExpireTime:userIdCookie];
    [self renewCookieExpireTime:usernameCookie];
    [self renewCookieExpireTime:passwordCookie];
    
    User *user = [User alloc];
    user.id = [NSNumber numberWithInteger:[userIdCookie.value integerValue]];
    user.username = usernameCookie.value;
    user.password = passwordCookie.value;
    
    return user;
}

- (NSHTTPCookie *) renewCookieExpireTime:(NSHTTPCookie *)cookie
{
    NSMutableDictionary *cookieProperties = (NSMutableDictionary *)[cookie properties] ;
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:86400 * 7] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];

    return newCookie;
}


@end
