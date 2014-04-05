//
//  LoginViewController.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-5.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction)signinClicked:(id)sender;
- (IBAction)backgroudTap:(id)sender;

@end
