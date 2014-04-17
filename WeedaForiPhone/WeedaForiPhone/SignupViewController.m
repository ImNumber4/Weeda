//
//  SignupViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-13.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

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
    NSCharacterSet *unacceptedInput = nil;
    switch (textField.tag) {
            // Assuming EMAIL_TextField.tag == 1001
        case 1001:
            self.usernameValidImageView.image = [UIImage imageNamed:@"wrong.png"];
            break;
            // Assuming PHONE_textField.tag == 1002
        case 1002:
            if ([self validateEmailWithString:self.txtEmail.text]) {
                self.emailValidImageView.image = [UIImage imageNamed:@"ok.png"];
            } else {
                self.emailValidImageView.image = [UIImage imageNamed:@"wrong.png"];
            }
            
            break;
        case 1003:
            if (self.txtPassword.text.length >= 8) {
                self.passwordValidImageView.image = [UIImage imageNamed:@"ok.png"];
            } else {
                self.passwordValidImageView.image = [UIImage imageNamed:@"worng.png"];
            }
            break;
        default:
            unacceptedInput = [[NSCharacterSet illegalCharacterSet] invertedSet];
            break;
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
            if (availableUsername && [self validateEmailWithString:self.txtEmail.text] && [self validatePassword:self.txtPassword.text]) {
                [self.btnSignup setEnabled:YES];
            }
            break;
    }
    return true;
}

-(void) validateTextFields {
    if ((self.txtUsername.text.length > 0) && self.txtPassword.text.length > 0 && self.txtEmail.text.length > 0) {
        [self.btnSignup setEnabled:YES];
    } else {
        [self.btnSignup setEnabled:NO];
    }
}

- (BOOL)validateUsername:(NSString *)username
{
//    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
//    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
//    user.username = [self.txtUsername text];
//    
//    
//    [[RKObjectManager sharedManager] postObject:user path:@"user/username" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        NSLog(@"Response: %@", mappingResult);
//        if (mappingResult.array.count == 0) {
//            availableUsername = true;
//        }
//        
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        NSLog(@"Failure login: %@", error.localizedDescription);
//    }];
//    
//    return availableUsername;
    
//    NSURL *url = [NSURL URLWithString:@"http://localhost/user/username"];
//    
//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
//    
//    NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error: nil ];
//    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", responseString);
//    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
//    
//    NSArray *results = [parsedObject valueForKey:@"users"];
//    self.users = [[NSMutableArray alloc] init];
//    for (NSDictionary *userDic in results) {
//        User *user = [[User alloc] init];
//        for (NSString *key in userDic) {
//            if ([user respondsToSelector:NSSelectorFromString(key)]) {
//                [user setValue:[userDic valueForKey:key] forKey:key];
//            }
//        }
//        [self.users addObject:user];
//    }
    return true;
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePassword:(NSString *)password
{
    if (password.length >= 8) {
        return true;
    } else {
        return false;
    }
}

@end
