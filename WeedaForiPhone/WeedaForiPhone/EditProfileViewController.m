//
//  EditProfileViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "EditProfileViewController.h"
#import "TabBarController.h"
#import "BlurView.h"

@interface EditProfileViewController ()
@property (nonatomic, strong) UIView *blurView;
@end

@implementation EditProfileViewController

const NSInteger BASIC_INFO_SECTION = 0;
const NSInteger USERNAME_ROW = 0;
const NSInteger EMAIL_ROW = 1;
const NSInteger USER_BIO_ROW = 2;

const NSInteger STORE_INFO_SECTION = 1;
const NSInteger STORENAME_ROW = 0;
const NSInteger PHONE_ROW = 1;
const NSInteger STREET_ROW = 2;
const NSInteger CITY_ROW = 3;
const NSInteger STATE_ROW = 4;
const NSInteger ZIP_ROW = 5;
const NSInteger COUNTRY_ROW = 6;



- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.tableFooterView = [[UIView alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(![USER_TYPE_USER isEqualToString:[self.userObject.user_type lowercaseString]]) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (BASIC_INFO_SECTION == section) {
        return 3;
    } else if (STORE_INFO_SECTION == section) {
        return 7;
    } else {
        return 0;
    }
}

- (UserInfoEditableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoEditableCell *cell = (UserInfoEditableCell *)[tableView dequeueReusableCellWithIdentifier:@"UserInfoEditableCell" forIndexPath:indexPath];
    cell.contentTextField.hidden = NO;
    cell.contentTextView.hidden = YES;
    if (indexPath.section == BASIC_INFO_SECTION) {
        if (indexPath.row == USERNAME_ROW) {
            cell.nameLabel.text = @"Username";
            cell.contentTextField.text = self.userObject.username;
            cell.contentTextField.placeholder = self.userObject.username;
        } else if (indexPath.row == EMAIL_ROW) {
            cell.nameLabel.text = @"Email";
            cell.contentTextField.text = self.userObject.email;
            cell.contentTextField.placeholder = self.userObject.email;
        } else if (indexPath.row == USER_BIO_ROW) {
            cell.nameLabel.text = @"Bio";
            cell.contentTextView.text = self.userObject.userDescription;
            cell.contentTextField.hidden = YES;
            cell.contentTextView.hidden = NO;
        }
    } else if (indexPath.section == STORE_INFO_SECTION) {
        if (indexPath.row == STREET_ROW) {
            cell.nameLabel.text = @"Street";
            cell.contentTextField.text = self.userObject.address_street;
            cell.contentTextField.placeholder = self.userObject.address_street;
        } else if (indexPath.row == CITY_ROW) {
            cell.nameLabel.text = @"City";
            cell.contentTextField.text = self.userObject.address_city;
            cell.contentTextField.placeholder = self.userObject.address_city;
        } else if (indexPath.row == STATE_ROW) {
            cell.nameLabel.text = @"State";
            cell.contentTextField.text = self.userObject.address_state;
            cell.contentTextField.placeholder = self.userObject.address_state;
        } else if (indexPath.row == ZIP_ROW) {
            cell.nameLabel.text = @"Zip";
            cell.contentTextField.text = self.userObject.address_zip;
            cell.contentTextField.placeholder = self.userObject.address_zip;
        } else if (indexPath.row == COUNTRY_ROW) {
            cell.nameLabel.text = @"Country";
            cell.contentTextField.text = self.userObject.address_country;
            cell.contentTextField.placeholder = self.userObject.address_country;
        } else if (indexPath.row == PHONE_ROW) {
            cell.nameLabel.text = @"Phone";
            cell.contentTextField.text = self.userObject.phone;
            cell.contentTextField.placeholder = self.userObject.phone;
        } else if (indexPath.row == STORENAME_ROW) {
            cell.nameLabel.text = @"Store Name";
            cell.contentTextField.text = self.userObject.storename;
            cell.contentTextField.placeholder = self.userObject.storename;
        }
    }
    cell.delegate = self;
    
    return cell;
}

- (void) finishModifying:(NSString *)text sender:(UITableViewCell *)sender
{
    CGPoint cellPosition = [sender convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:cellPosition];
    if (indexPath.section == BASIC_INFO_SECTION) {
        if (indexPath.row == USERNAME_ROW) {
            [self.userObject setUsername:text];
        } else if (indexPath.row == EMAIL_ROW) {
            [self.userObject setEmail:text];
        } else if (indexPath.row == USER_BIO_ROW) {
            [self.userObject setUserDescription:text];
        }
    } else if (indexPath.section == STORE_INFO_SECTION) {
        if (indexPath.row == STREET_ROW) {
            [self.userObject setAddress_street:text];
        } else if (indexPath.row == CITY_ROW) {
            [self.userObject setAddress_city:text];
        } else if (indexPath.row == STATE_ROW) {
            [self.userObject setAddress_state:text];
        } else if (indexPath.row == ZIP_ROW) {
            [self.userObject setAddress_zip:text];
        } else if (indexPath.row == COUNTRY_ROW) {
            [self.userObject setAddress_country:text];
        } else if (indexPath.row == PHONE_ROW) {
            [self.userObject setPhone:text];
        } else if (indexPath.row == STORENAME_ROW) {
            [self.userObject setStorename:text];
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel *placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 25)];
    [placeHolder setBackgroundColor:[UIColor colorWithRed:105.0/255.0 green:210.0/255.0 blue:245.0/255.0 alpha:0.8]];
    [sectionText setFont:[UIFont boldSystemFontOfSize:12]];
    [sectionText setTextColor:[UIColor whiteColor]];
    if (BASIC_INFO_SECTION == section) {
        [sectionText setText:@"Basic Info"];
    } else if (STORE_INFO_SECTION == section) {
        [sectionText setText:@"Store Info"];
    }
    [view addSubview:placeHolder];
    [view addSubview:sectionText];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BASIC_INFO_SECTION && indexPath.row == USER_BIO_ROW) {
        return 100;
    }
    return 40;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect keyboardFrameInWindowsCoordinates;
    [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindowsCoordinates];
    CGSize kbSize = keyboardFrameInWindowsCoordinates.size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.table.contentInset.top, 0.0, kbSize.height, 0.0);
    self.table.contentInset = contentInsets;
    self.table.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.table.contentInset.top, 0.0, 0.0, 0.0);
    self.table.contentInset = contentInsets;
    self.table.scrollIndicatorInsets = contentInsets;
    
}

- (IBAction) save: (id) sender
{
    [self.view endEditing:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    self.blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.blurView.tag = 1001;
    UIImage * image = [UIImage imageNamed:@"Yes.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.blurView addSubview:imageView];
    imageView.hidden = YES;
    [imageView setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    [imageView setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y - 150)];
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 50.0)];
    label.text = @"Updating...";
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.backgroundColor = [UIColor clearColor];
    [label setEditable:NO];
    [label setSelectable:NO];
    [self.blurView addSubview:label];
    [self.view addSubview:self.blurView];
    [label setCenter:CGPointMake(imageView.center.x, imageView.center.y)];
    [label setFrame:CGRectMake(label.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + 10, label.frame.size.width, label.frame.size.height)];
    [[RKObjectManager sharedManager] postObject:self.userObject path:@"user/update" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        imageView.hidden = NO;
        if(mappingResult.array != nil && [mappingResult.array count] > 0) {
            
            [imageView setImage:[UIImage imageNamed:@"No.png"]];
            [label setTextAlignment:NSTextAlignmentLeft];
            label.text = @"Failed to update profile. The following things need to be corrected:";
            CGSize tvsize = [label sizeThatFits:CGSizeMake(label.frame.size.width, label.frame.size.height)];
            [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, tvsize.height)];
            
            UITextView *errorMessageView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 50.0)];
            NSMutableString *errorMessage = [[NSMutableString alloc] init];
            for (RKErrorMessage *error in mappingResult.array) {
                [errorMessage appendString:@" * "];
                [errorMessage appendString:error.errorMessage];
                [errorMessage appendString:@"\n"];
            }
            errorMessageView.text = errorMessage;
            [self.blurView addSubview:errorMessageView];
            tvsize = [errorMessageView sizeThatFits:CGSizeMake(label.frame.size.width, label.frame.size.height)];
            [errorMessageView setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height + 10, label.frame.size.width, MIN(200.0,tvsize.height))];
            [errorMessageView setFont:[UIFont systemFontOfSize:12]];
            [errorMessageView setTextAlignment:NSTextAlignmentLeft];
            errorMessageView.backgroundColor = [UIColor clearColor];
            [errorMessageView setEditable:NO];
            [errorMessageView setSelectable:NO];
            
            UIButton *okayButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 25.0)];
            [okayButton setTitle:@"Got it" forState:UIControlStateNormal];
            [okayButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [okayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [okayButton setBackgroundColor:[ColorDefinition blueColor]];
            [self.blurView addSubview:okayButton];
            [okayButton setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y)];
            [okayButton setFrame:CGRectMake(okayButton.frame.origin.x, errorMessageView.frame.origin.y + errorMessageView.frame.size.height + 10, okayButton.frame.size.width, okayButton.frame.size.height)];
            [okayButton addTarget:self action:@selector(okayClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
        } else {
            label.text = @"Successfully updated profile.";
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(cancel:) userInfo:nil repeats:YES];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to save post: %@", error.localizedRecoverySuggestion);
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }];
}

- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) okayClicked: (id) sender {
    [self.blurView removeFromSuperview];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}


@end
