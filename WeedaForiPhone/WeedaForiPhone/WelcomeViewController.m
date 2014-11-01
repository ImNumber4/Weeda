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

@property (strong, nonatomic) UITextField *txtUsername;
@property (strong, nonatomic) UITextField *txtPassword;
@property (strong, nonatomic) UIButton *btnSignIn;
@property (strong, nonatomic) UIButton *btnSignUp;
@property (strong, nonatomic) UILabel *lbForgotPw;

@property (nonatomic, strong) UIImageView *titleImage;

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
    
    double leftPadding = 20;
    
    self.txtUsername = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 175, self.view.frame.size.width - 2 * leftPadding, 35)];
    [self.view addSubview:self.txtUsername];
    self.txtUsername.alpha = 0;
    [self.txtUsername setFont:[UIFont systemFontOfSize:14]];
    self.txtUsername.placeholder = @"Username";
    self.txtUsername.textColor = [ColorDefinition greenColor];
    self.txtUsername.layer.borderWidth = 1;
    self.txtUsername.layer.borderColor = [[UIColor whiteColor] CGColor];
    [UIViewHelper insertLeftPaddingToTextField:self.txtUsername width:10];
    self.txtUsername.backgroundColor = [UIColor whiteColor];
    self.txtUsername.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtUsername.returnKeyType = UIReturnKeyGo;
    self.txtUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtUsername.delegate = self;
    [UIViewHelper roundCorners:self.txtUsername byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight radius:5];
    
    self.txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(self.txtUsername.frame.origin.x, self.txtUsername.frame.origin.y + self.txtUsername.frame.size.height + 1,  self.txtUsername.frame.size.width,  self.txtUsername.frame.size.height)];
    [self.view addSubview:self.txtPassword];
    self.txtPassword.alpha = 0;
    [self.txtPassword setFont:self.txtUsername.font];
    self.txtPassword.placeholder = @"Password";
    self.txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtPassword.returnKeyType = UIReturnKeyGo;
    self.txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtPassword.delegate = self;
    self.txtPassword.textColor = [ColorDefinition greenColor];
    self.txtPassword.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtPassword.layer.borderWidth = 1;
    self.txtPassword.secureTextEntry = true;
    [UIViewHelper insertLeftPaddingToTextField:self.txtPassword width:10];
    self.txtPassword.backgroundColor = [UIColor whiteColor];
    [UIViewHelper roundCorners:self.txtPassword byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:5];
    
    double lbForgotPwWidth = 105;
    double lbForgotPwHeight = 21;
    self.lbForgotPw = [[UILabel alloc] initWithFrame:CGRectMake(self.txtPassword.frame.origin.x + self.txtPassword.frame.size.width - lbForgotPwWidth, self.txtPassword.frame.origin.y + self.txtPassword.frame.size.height + 1, lbForgotPwWidth, lbForgotPwHeight)];
    self.lbForgotPw.text = @"Forgot Password?";
    [self.lbForgotPw setFont:[UIFont systemFontOfSize:12]];
    [self.lbForgotPw setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.lbForgotPw];
    
    self.btnSignIn = [[UIButton alloc] initWithFrame:CGRectMake(self.txtUsername.frame.origin.x, self.lbForgotPw.frame.origin.y + self.lbForgotPw.frame.size.height + 20, self.txtUsername.frame.size.width, self.txtUsername.frame.size.height)];
    [self.btnSignIn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchDown];
    [self.btnSignIn setBackgroundColor:[ColorDefinition darkGreenColor]];
    [self.btnSignIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.btnSignIn.titleLabel setTextColor:[UIColor whiteColor]];
    [self.btnSignIn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    self.btnSignIn.layer.cornerRadius = 5;
    [self.view addSubview:self.btnSignIn];
    
    self.btnSignUp = [[UIButton alloc] initWithFrame:CGRectMake(self.txtUsername.frame.origin.x, self.btnSignIn.frame.origin.y + self.btnSignIn.frame.size.height + 5, self.txtUsername.frame.size.width, self.txtUsername.frame.size.height)];
    [self.btnSignUp addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchDown];
    [self.btnSignUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.btnSignUp.titleLabel setTextColor:[UIColor whiteColor]];
    [self.btnSignUp.titleLabel setFont:self.lbForgotPw.font];
    [self.view addSubview:self.btnSignUp];
    
    self.btnSignIn.alpha = 0;
    self.btnSignUp.alpha = 0;
    self.lbForgotPw.alpha = 0;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self signIn:textField];
    return YES;
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

- (void)signIn:(id)sender {
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

- (void)signUp:(id)sender {
    [self performSegueWithIdentifier:@"signUp" sender:self];
}

- (void)backgroudTab:(id)sender {
    [self.view endEditing:YES];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height/2.0 - 25)];
    } completion:^(BOOL finished) {
        
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height/2.0)];
    } completion:^(BOOL finished) {
        
    }];
}

@end
