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
#import "UIViewHelper.h"

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
    self.view.backgroundColor = [ColorDefinition greenColor];
    
    self.titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(65, 190, 192, 27)];
    self.titleImage.image = [UIImage imageNamed:@"title.png"];
    [self.view addSubview:self.titleImage];
    [self.view bringSubviewToFront:self.titleImage];
    
    self.txtUsername.alpha = 0;
    self.txtUsername.placeholder = @"Username";
    [self.txtUsername setFrame:CGRectMake(20, self.txtUsername.frame.origin.y, self.view.frame.size.width - 40, 35)];
    self.txtUsername.textColor = [ColorDefinition greenColor];
    self.txtUsername.layer.borderWidth = 1;
    self.txtUsername.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtUsername.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.txtUsername.frame.size.height)];
    self.txtUsername.leftViewMode = UITextFieldViewModeAlways;
    self.txtUsername.backgroundColor = [UIColor whiteColor];
    self.txtUsername.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    [UIViewHelper roundCorners:self.txtUsername byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight radius:5];
    
    self.txtPassword.alpha = 0;
    self.txtPassword.placeholder = @"Password";
    self.txtPassword.textColor = [ColorDefinition greenColor];
    self.txtPassword.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtPassword.layer.borderWidth = 1;
    self.txtPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.txtUsername.frame.size.height)];
    self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
    self.txtPassword.backgroundColor = [UIColor whiteColor];
    [self.txtPassword setFrame:CGRectMake(self.txtUsername.frame.origin.x, self.txtUsername.frame.origin.y + self.txtUsername.frame.size.height + 1,  self.txtUsername.frame.size.width,  self.txtUsername.frame.size.height)];
    self.txtPassword.backgroundColor = [UIColor whiteColor];
    [UIViewHelper roundCorners:self.txtPassword byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:5];
    
    [self.lbForgotPw setFrame:CGRectMake(self.lbForgotPw.frame.origin.x, self.txtPassword.frame.origin.y + self.txtPassword.frame.size.height + 1, self.lbForgotPw.frame.size.width, self.lbForgotPw.frame.size.height)];
    [self.btnSignIn setBackgroundColor:[ColorDefinition darkGreenColor]];
    self.btnSignIn.layer.cornerRadius = 5;
    [self.btnSignIn setFrame:CGRectMake(self.txtUsername.frame.origin.x, self.lbForgotPw.frame.origin.y + self.lbForgotPw.frame.size.height + 20, self.txtUsername.frame.size.width, self.txtUsername.frame.size.height)];
    [self.btnSignUp setFrame:CGRectMake(self.txtUsername.frame.origin.x, self.btnSignIn.frame.origin.y + self.btnSignIn.frame.size.height + 5, self.txtUsername.frame.size.width, self.txtUsername.frame.size.height)];
    [self.btnSignUp.titleLabel setFont:self.lbForgotPw.font];
    
    self.btnSignIn.alpha = 0;
    self.btnSignUp.alpha = 0;
    self.lbForgotPw.alpha = 0;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
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
        self.titleImage.center = CGPointMake(self.titleImage.center.x, 120);
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
        self.titleImage.center = CGPointMake(self.titleImage.center.x, 190);
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
