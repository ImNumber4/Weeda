//
//  WelcomeViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-7.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "WelcomeViewController.h"

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
    NSHTTPCookie *cookie = [self checkCookies];
    if (!cookie) {
        sleep(2);
        [self performSegueWithIdentifier:@"login" sender:self];
    } else {
        //renew cookie expire time;
        NSHTTPCookie * newCookie = [self renewCookieExpireTime:cookie];
        
        //check cookie authentication
        //success, go to MasterView
        self.currentUser = [NSEntityDescription
                            insertNewObjectForEntityForName:@"User"
                            inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        self.currentUser.id = [NSNumber numberWithInt:[newCookie.value integerValue]];
        
        sleep(2);
        [self performSegueWithIdentifier:@"masterView" sender:self];
        
        //TODO: failure, go to LoginView
        
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"masterView"]) {
        UINavigationController *nav = [segue destinationViewController];
        MasterViewController *masterViewController = (MasterViewController *)nav.topViewController;
        [masterViewController setCurrentUser:self.currentUser];
    }
}

- (NSHTTPCookie *) checkCookies
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return nil;
    }
    
    if (cookies.count == 1) {
        NSHTTPCookie *cookie = [cookies objectAtIndex:0];
        if ([cookie.expiresDate compare:[NSDate date]] == NSOrderedAscending) {
            //cookie expired, delete cookie
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            return nil;
        } else {
            return cookie;
        }
    }
    
    //if there are more than one cookies, save the first one which not expired, delete others.
    NSHTTPCookie *savedCookie = nil;
    for (NSHTTPCookie *cookie in cookies) {
        if (!savedCookie && [cookie.expiresDate compare:[NSDate date]] == NSOrderedDescending) {
            savedCookie = cookie;
        } else {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    return savedCookie;
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
