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
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || !cookies.count) {
        sleep(2);
        [self performSegueWithIdentifier:@"login" sender:self];
    } else {
        //check cookie authentication
        //success, go to MasterView
        self.currentUser = [NSEntityDescription
                            insertNewObjectForEntityForName:@"User"
                            inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        NSString *userId = nil;
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"user_id"]) {
                userId = cookie.value;
            }
            //renew cookie expire time;

        }
        self.currentUser.id = [NSNumber numberWithInt:[userId intValue]];
        sleep(2);
        [self performSegueWithIdentifier:@"masterView" sender:self];
        
        //failure, go to LoginView
        
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

- (void) renewCookieExpireTime:(NSHTTPCookie *)cookie
{
    
}


@end
