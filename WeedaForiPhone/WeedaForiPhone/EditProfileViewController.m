//
//  EditProfileViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "EditProfileViewController.h"
#import "TabBarController.h"

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
    
    [[RKObjectManager sharedManager] postObject:self.userObject path:@"user/update" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Successfully updated profile.");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving post: %@", error.localizedDescription);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
