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

static NSString * USER_ID_COOKIE_NAME = @"user_id";
static NSString * USERNAME_COOKIE_NAME = @"username";
static NSString * PASSWORD_COOKIE_NAME = @"password";

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
    self.txtUsername.placeholder = @"Username";
    self.txtUsername.textColor = [UIColor whiteColor];
    self.txtUsername.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtUsername.layer.borderWidth = 1.0;
    self.txtUsername.layer.cornerRadius = 7.0;
    self.txtUsername.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
    
    self.txtPassword.alpha = 0;
    self.txtPassword.placeholder = @"Password";
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
    sleep(1);
    [self checkCookiesAndGetCurrentUser];
}

- (void) showLoginUI
{
    [UIView animateWithDuration:0.5 animations:^{
        self.titleImage.center = CGPointMake(self.titleImage.center.x, self.titleImage.center.y - 70);
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

- (void) hideLoginUI
{
    [UIView animateWithDuration:0.5 animations:^{
        self.txtUsername.alpha = 0;
        self.txtPassword.alpha = 0;
        self.btnSignUp.alpha = 0;
        self.btnSignIn.alpha = 0;
        self.lbForgotPw.alpha = 0;
        self.titleImage.center = CGPointMake(self.titleImage.center.x, self.titleImage.center.y + 70);
    }];
}

- (void)showMasterView:(User *)user
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = user;
    [self performSegueWithIdentifier:@"masterView" sender:self];
}

#pragma mark - Navigation

- (void) checkCookiesAndGetCurrentUser
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //everytime, first clear all the login cookies. Login will refresh it
    [appDelegate clearLoginCookies];
    if (appDelegate.currentUser) {
        [self signInThoughServer:appDelegate.currentUser];
    } else {
        [self showLoginUI];
        return;
    }
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

- (IBAction)signIn:(id)sender {
    if ([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""]) {
        [self alertStatus:@"Please enter Username and Password" :@"" :0];
        return;
    }
    User * user = [User alloc];
    user.username = [self.txtUsername text];
    user.password = [self.txtPassword text];
    [self hideLoginUI];
    [self signInThoughServer:user];
}

- (void)signInThoughServer:(User *) user {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[RKObjectManager sharedManager] postObject:user path:@"user/login" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [appDelegate populateCurrentUserFromCookie];
        [self performSegueWithIdentifier:@"masterView" sender:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure login: %@", error.localizedDescription);
        [self alertStatus:@"Failed to login. Please enter the correct Username and Password." :@"" :0];
        [self showLoginUI];
    }];
}

- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier:@"signUp" sender:self];
}

- (IBAction)backgroudTab:(id)sender {
    [self.view endEditing:YES];
}
@end
