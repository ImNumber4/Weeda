//
//  LoginViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-5.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TabBarController.h"
#import "MasterViewController.h"
#import "SignupViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (IBAction)signupClicked:(id)sender {
}

- (IBAction)signinClicked:(id)sender {
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
            [self performSegueWithIdentifier:@"loginSuccess" sender:self];
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


- (IBAction)backgroudTap:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/registerDevice/%@", appDelegate.deviceToken] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"registerDevice failed with error: %@", error);
    }];
    
    
    appDelegate.currentUser = self.currentUser;
}

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

@end
