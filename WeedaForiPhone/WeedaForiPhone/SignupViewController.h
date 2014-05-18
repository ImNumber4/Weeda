//
//  SignupViewController.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-13.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIImageView *usernameValidImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailValidImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordValidImageView;

@property (weak, nonatomic) IBOutlet UIButton *btnSignup;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

- (IBAction)signupClicked:(id)sender;
- (IBAction)cancel:(id)sender;


@end
