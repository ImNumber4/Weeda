//
//  LoginViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-5.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "LoginViewController.h"

#import "MasterViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentUser = [NSEntityDescription
                        insertNewObjectForEntityForName:@"User"
                        inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    
    self.currentUser.id = [NSNumber numberWithInt:3];
    self.currentUser.username = @"test";
    self.currentUser.email = @"test@test.com";
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

- (IBAction)signinClicked:(id)sender {
//    @try {
//        if ([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""]) {
//            [self alertStatus:@"Please input your Email and Password" :@"Sign In Failed." :0];
//            return;
//        }
//        
//        
//        
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception: %@", exception);
//        [self alertStatus:@"Sign in Failed." :@"Error!" :0];
//    }
//    @finally {
//        //
//    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loginSuccess"]) {
        UINavigationController *nav = [segue destinationViewController];
        MasterViewController *masterViewController = (MasterViewController *)nav.topViewController;
        [masterViewController setCurrentUser:self.currentUser];
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

@end
