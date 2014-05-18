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

@interface WelcomeViewController () {
    
}
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UILabel *lbForgotPw;

@property (nonatomic, retain) UIImageView *titleImage;

- (IBAction)backgroudTab:(id)sender;

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
    self.view.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
    
    self.titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(65, 170, 192, 27)];
    self.titleImage.image = [UIImage imageNamed:@"title.png"];
    [self.view addSubview:self.titleImage];
    [self.view bringSubviewToFront:self.titleImage];
    
    self.txtUsername.alpha = 0;
    self.txtUsername.placeholder = @"username or email";
    self.txtUsername.textColor = [UIColor whiteColor];
    self.txtUsername.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtUsername.layer.borderWidth = 1.0;
    self.txtUsername.layer.cornerRadius = 7.0;
    self.txtUsername.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
    
    self.txtPassword.alpha = 0;
    self.txtPassword.placeholder = @"password";
    self.txtPassword.textColor = [UIColor whiteColor];
    self.txtPassword.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtPassword.layer.borderWidth = 1.0;
    self.txtPassword.layer.cornerRadius = 7.0;
    self.txtPassword.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
    
    self.btnSignIn.alpha = 0;
    self.btnSignUp.alpha = 0;
    self.lbForgotPw.alpha = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    User *user = [self checkCookiesAndGetCurrentUser];
    if (user) {
        sleep(1);
        [self showMasterView:user];
    } else {
        sleep(2);
        [UIView animateWithDuration:0.5 animations:^{
//            self.titleImageView.center = CGPointMake(self.titleImageView.center.x, 100);
            self.titleImage.center = CGPointMake(self.titleImage.center.x, 100);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.txtUsername.alpha = 1;
                self.txtPassword.alpha = 1;
                self.btnSignUp.alpha = 1;
                self.btnSignIn.alpha = 1;
                self.lbForgotPw.alpha = 1;
            }];
        }];
    }
}

- (void)showMasterView:(User *)user
{
    //check cookie authentication
    //success, go to MasterView
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = user;
    [self performSegueWithIdentifier:@"masterView" sender:self];
    
    //TODO: failure, go to LoginView
    
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


- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

- (void) setCurrentUser
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"user_id"]) {
            self.currentUser.id = [NSNumber numberWithInteger:[cookie.value integerValue]];
        } else if ([cookie.name isEqualToString:@"username"]) {
            self.currentUser.username = cookie.value;
        } else if ([cookie.name isEqualToString:@"password"]) {
            self.currentUser.password = cookie.value;
        } else {
            NSLog(@"Extra cookie in the app, cookie name is %@", cookie.name);
        }
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = self.currentUser;
}

- (IBAction)signIn:(id)sender {
    @try {
        if ([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""]) {
            [self alertStatus:@"Please input your Email and Password" :@"Sign In Failed." :0];
            return;
        }
        
        self.currentUser = [User alloc];
        self.currentUser.username = [self.txtUsername text];
        self.currentUser.password = [self.txtPassword text];
        
        [[RKObjectManager sharedManager] postObject:self.currentUser path:@"user/login" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"Response: %@", mappingResult);
            [self setCurrentUser];
            [self performSegueWithIdentifier:@"masterView" sender:self];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Failure login: %@", error.localizedDescription);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        [self alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
    @finally {
        //
    }
}

- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier:@"signUp" sender:self];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"signUp"]) {
//        WelcomeViewController *controller = segue.sourceViewController;
//        controller.
//    }
//}

- (NSHTTPCookie *) setCookie:(NSString *)cookieString
{
    NSArray *tmpArray = [cookieString componentsSeparatedByString:@";"];
    NSArray *keyValue = [[tmpArray objectAtIndex:0] componentsSeparatedByString:@"="];
    NSString *key = [keyValue objectAtIndex:0];
    NSString *value = [keyValue objectAtIndex:1];
    
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:key forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:86400 * 7] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    return cookie;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroudTab:(id)sender {
        [self.view endEditing:YES];
}
@end
