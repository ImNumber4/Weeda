//
//  SignupViewController.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-13.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction) cancel: (id) sender;
- (IBAction)signupClicked:(id)sender;

@end
