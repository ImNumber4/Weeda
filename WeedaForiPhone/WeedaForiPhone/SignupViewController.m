//
//  SignupViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-13.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "AppDelegate.h"
#import "SignupViewController.h"

@interface SignupViewController ()


@end

@implementation SignupViewController

#define ALPHA                   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define NUMERIC                 @"1234567890"
#define ALPHA_NUMERIC           ALPHA NUMERIC

bool availableUsername = false;

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    [self.btnSignup setEnabled:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signupClicked:(id)sender {
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    user.id = [NSNumber numberWithInt:-1];
    user.username = self.txtUsername.text;
    user.password = self.txtPassword.text;
    user.email = self.txtEmail.text;
    user.time = [NSDate date];
    
    [[RKObjectManager sharedManager] postObject:user path:@"user/signup" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Response: %@", mappingResult);
        
        [self setCurrentUser];
        [self performSegueWithIdentifier:@"signupSuccess" sender:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    switch (textField.tag) {
        case 1001:
            self.usernameValidImageView.image = [UIImage imageNamed:@"wrong.png"];
            break;
        case 1002:
            if ([self validateEmailWithString:textField.text]) {
                self.emailValidImageView.image = [UIImage imageNamed:@"ok.png"];
            } else {
                self.emailValidImageView.image = [UIImage imageNamed:@"wrong.png"];
            }
            break;
        case 1003:
            if ([self validatePassword:textField.text]) {
                self.passwordValidImageView.image = [UIImage imageNamed:@"ok.png"];
            } else {
                self.passwordValidImageView.image = [UIImage imageNamed:@"wrong.png"];
            }
            break;
        default:
            break;
    }
    if (availableUsername && [self validateEmailWithString:self.txtEmail.text] && [self validatePassword:self.txtPassword.text]) {
        [self.btnSignup setEnabled:YES];
    }
    return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1001:
            if ([self validateUsername:textField.text]) {
                self.usernameValidImageView.image = [UIImage imageNamed:@"ok.png"];
            } else {
                self.usernameValidImageView.image = [UIImage imageNamed:@"wrong.png"];
            }
            break;
        case 1002:
            NSLog(@"email");
            break;
        case 1003:
            NSLog(@"password");
            break;
        default:
            break;
    }
    if (availableUsername && [self validateEmailWithString:self.txtEmail.text] && [self validatePassword:self.txtPassword.text]) {
        [self.btnSignup setEnabled:YES];
    }
    return true;
}

- (BOOL)validateUsername:(NSString *)username
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/user/username/%@", username]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error: nil ];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseString);
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
    
    BOOL result = [[parsedObject valueForKey:@"exist"] boolValue];
    if (result) {
        availableUsername = false;
        return false;
    } else {
        availableUsername = true;
        return true;
    }
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePassword:(NSString *)password
{
    if (password.length >= 7) {
        return true;
    } else {
        return false;
    }
}

- (void) setCurrentUser
{
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];

    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"user_id"]) {
            user.id = [NSNumber numberWithInteger:[cookie.value integerValue]];
        } else if ([cookie.name isEqualToString:@"username"]) {
            user.username = cookie.value;
        } else if ([cookie.name isEqualToString:@"password"]) {
            user.password = cookie.value;
        } else {
            NSLog(@"Extra cookie in the app, cookie name is %@", cookie.name);
        }
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentUser:user];
}

@end
