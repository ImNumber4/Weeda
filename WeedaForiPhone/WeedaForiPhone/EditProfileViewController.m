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

@property (nonatomic, strong) BlurView *blurView;
@property BOOL addressChanged;
@property (nonatomic, strong) CLPlacemark *suggestedAddress;

@end

@implementation EditProfileViewController

const NSInteger BASIC_INFO_SECTION = 0;
const NSInteger EMAIL_ROW = 0;
const NSInteger USER_BIO_ROW = 1;

const NSInteger STORE_INFO_SECTION = 1;
const NSInteger STORENAME_ROW = 0;
const NSInteger PHONE_ROW = 1;
const NSInteger STREET_ROW = 2;
const NSInteger CITY_ROW = 3;
const NSInteger STATE_ROW = 4;
const NSInteger ZIP_ROW = 5;
const NSInteger COUNTRY_ROW = 6;

const NSInteger PADDING = 10;

const NSInteger MAP_VIEW_IN_BLUR_VIEW_TAG = 11;
const NSInteger MAP_QUESTION_LABEL_IN_BLUR_VIEW_TAG = 12;
const NSInteger MAP_USE_MY_ADDRESS_IN_BLUR_VIEW_TAG = 13;
const NSInteger MAP_RE_ENTER_ADDRESS_BUTTON_IN_BLUR_VIEW_TAG = 14;
const NSInteger MAP_USE_SUGGESTED_ADDRESS_BUTTON_IN_BLUR_VIEW_TAG = 15;


const NSInteger RESULT_IMAGE_VIEW_IN_BLUR_VIEW_TAG = 21;
const NSInteger RESULT_LABEL_IN_BLUR_VIEW = 22;
const NSInteger RESULT_TEXT_VIEW_IN_BLUR_VIEW = 23;
const NSInteger RESULT_OKAY_BUTTON_IN_BLUR_VIEW = 24;

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
    self.addressChanged = NO;
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
        return 2;
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
        if (indexPath.row == EMAIL_ROW) {
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

- (void) finishModifying:(NSString *)text sender:(UserInfoEditableCell *)sender
{
    CGPoint cellPosition = [sender convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:cellPosition];
    if (indexPath.section == BASIC_INFO_SECTION) {
        if (indexPath.row == EMAIL_ROW) {
            [self.userObject setEmail:text];
        } else if (indexPath.row == USER_BIO_ROW) {
            [self.userObject setUserDescription:text];
        }
    } else if (indexPath.section == STORE_INFO_SECTION) {
        if (indexPath.row == STREET_ROW) {
            [self.userObject setAddress_street:text];
            if ([sender.contentTextField.text caseInsensitiveCompare:sender.contentTextField.placeholder] != NSOrderedSame) {
                self.addressChanged = YES;
            }
        } else if (indexPath.row == CITY_ROW) {
            [self.userObject setAddress_city:text];
            if ([sender.contentTextField.text caseInsensitiveCompare:sender.contentTextField.placeholder] != NSOrderedSame) {
                self.addressChanged = YES;
            }
        } else if (indexPath.row == STATE_ROW) {
            [self.userObject setAddress_state:text];
            if ([sender.contentTextField.text caseInsensitiveCompare:sender.contentTextField.placeholder] != NSOrderedSame) {
                self.addressChanged = YES;
            }
        } else if (indexPath.row == ZIP_ROW) {
            [self.userObject setAddress_zip:text];
            self.addressChanged = YES;
            if ([sender.contentTextField.text caseInsensitiveCompare:sender.contentTextField.placeholder] != NSOrderedSame) {
                self.addressChanged = YES;
            }
        } else if (indexPath.row == COUNTRY_ROW) {
            [self.userObject setAddress_country:text];
            if ([sender.contentTextField.text caseInsensitiveCompare:sender.contentTextField.placeholder] != NSOrderedSame) {
                self.addressChanged = YES;
            }
        } else if (indexPath.row == PHONE_ROW) {
            self.addressChanged = YES;
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
    
    if (!self.blurView) {
        self.blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    [self.view addSubview:self.blurView];
    
    for (UIView *subView in self.blurView.subviews) {
        //all the views we will add/have added will have non zero tag
        if (subView.tag > 0) {
            subView.hidden = true;
        }
    }
    
    if (self.addressChanged) {
        if (self.geocoder == nil) {
            self.geocoder = [[CLGeocoder alloc] init];
        }
        NSString *searchAddress = [self.userObject getFormatedAddress];
        [self.geocoder geocodeAddressString:searchAddress
                          completionHandler:^(NSArray* placemarks, NSError* error){
                              if (placemarks && placemarks.count > 0) {
                                  self.suggestedAddress = [placemarks objectAtIndex:0];
                              } else {
                                  self.suggestedAddress = nil;
                              }
                              
                              NSString * userEnteredAddress = [self.userObject getFormatedAddress];
                              
                              MKMapView * mapView = (MKMapView *)[self.view viewWithTag:MAP_VIEW_IN_BLUR_VIEW_TAG];
                              if (!mapView) {
                                  CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
                                  mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height + statusBarSize.height, self.blurView.frame.size.width, 260)];
                                  mapView.tag = MAP_VIEW_IN_BLUR_VIEW_TAG;
                                  [self.blurView addSubview:mapView];
                                  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPress:)];
                                  longPressGesture.minimumPressDuration = 1.0;
                                  [mapView addGestureRecognizer:longPressGesture];
                              }
                              mapView.hidden = false;
                              
                              UITextView *mapQuestionLabel = (UITextView*)[self.view viewWithTag:MAP_QUESTION_LABEL_IN_BLUR_VIEW_TAG];
                              if (!mapQuestionLabel) {
                                  mapQuestionLabel = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.blurView.frame.size.width - PADDING, 110.0)];
                                  mapQuestionLabel.tag = MAP_QUESTION_LABEL_IN_BLUR_VIEW_TAG;
                                  mapQuestionLabel.editable = false;
                                  mapQuestionLabel.selectable = false;
                                  [mapQuestionLabel setTextAlignment:NSTextAlignmentLeft];
                                  [mapQuestionLabel setBackgroundColor:[UIColor clearColor]];
                                  [mapQuestionLabel setFont:[UIFont systemFontOfSize:12]];
                                  [self.blurView addSubview:mapQuestionLabel];
                                  [mapQuestionLabel setCenter:CGPointMake(self.blurView.center.x, mapView.frame.origin.y + mapView.frame.size.height + mapQuestionLabel.frame.size.height/2.0 + PADDING)];
                              }
                              mapQuestionLabel.hidden = false;
                              if (self.suggestedAddress) {
                                  mapQuestionLabel.text = [NSString stringWithFormat:@"You entered: %@. We found the best match as: %@. Before clicking save please long press on the correct spot on the map to move the pin to the right location if it is not correctly marked.", userEnteredAddress, [User getFormatedAddressWithPlaceMark:self.suggestedAddress]];
                              } else {
                                  mapQuestionLabel.text = [NSString stringWithFormat:@"You entered: %@. We could not find any matched location. Please make sure the address you entered is correct. If yes, you can still save the address that you entered and long press on the correct spot on the map to move the pin to the right location so it can be correctly marked.", userEnteredAddress];
                              }
                              
                              CLLocationCoordinate2D zoomLocation;
                              if (self.suggestedAddress) {
                                  zoomLocation = self.suggestedAddress.location.coordinate;
                              } else {
                                  //default to seattle
                                  zoomLocation = CLLocationCoordinate2DMake(47.6097, -122.3331);
                              }
                              self.userObject.latitude = [NSNumber numberWithDouble:zoomLocation.latitude];
                              self.userObject.longitude = [NSNumber numberWithDouble:zoomLocation.longitude];
                              MKCoordinateSpan span = self.suggestedAddress ? MKCoordinateSpanMake(0.005, 0.005) : mapView.region.span;
                              MKCoordinateRegion region = MKCoordinateRegionMake(zoomLocation, span);
                              [mapView setRegion:region animated:YES];
                              [mapView addAnnotation:self.userObject];
                              
                              UIButton *useSuggestedAddressButton = (UIButton *)[self.view viewWithTag:MAP_USE_SUGGESTED_ADDRESS_BUTTON_IN_BLUR_VIEW_TAG];
                              if (!useSuggestedAddressButton) {
                                  useSuggestedAddressButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.blurView.frame.size.width - PADDING * 2, 25.0)];
                                  useSuggestedAddressButton.tag = MAP_USE_SUGGESTED_ADDRESS_BUTTON_IN_BLUR_VIEW_TAG;
                                  [useSuggestedAddressButton setTitle:@"Use the suggested address & Save" forState:UIControlStateNormal];
                                  [self.blurView addSubview:useSuggestedAddressButton];
                                  [useSuggestedAddressButton setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y)];
                                  [useSuggestedAddressButton setFrame:CGRectMake(useSuggestedAddressButton.frame.origin.x, mapQuestionLabel.frame.origin.y + mapQuestionLabel.frame.size.height + PADDING, useSuggestedAddressButton.frame.size.width, useSuggestedAddressButton.frame.size.height)];
                                  [useSuggestedAddressButton addTarget:self action:@selector(saveWithSuggestedAddress:) forControlEvents:UIControlEventTouchUpInside];
                              }
                              useSuggestedAddressButton.hidden = false;
                              if (self.suggestedAddress) {
                                  [self decorateButton:useSuggestedAddressButton color:[ColorDefinition greenColor]];
                                  useSuggestedAddressButton.enabled = true;
                              } else {
                                  [self decorateButton:useSuggestedAddressButton color:[ColorDefinition grayColor]];
                                  useSuggestedAddressButton.enabled = false;
                              }
                              
                              UIButton *useMyAddressButton = (UIButton *)[self.view viewWithTag:MAP_USE_MY_ADDRESS_IN_BLUR_VIEW_TAG];
                              if (!useMyAddressButton) {
                                  useMyAddressButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, useSuggestedAddressButton.frame.size.width, useSuggestedAddressButton.frame.size.height)];
                                  useMyAddressButton.tag = MAP_USE_MY_ADDRESS_IN_BLUR_VIEW_TAG;
                                  [self decorateButton:useMyAddressButton color:[ColorDefinition blueColor]];
                                  [useMyAddressButton setTitle:@"Use the address I entered & Save" forState:UIControlStateNormal];
                                  [self.blurView addSubview:useMyAddressButton];
                                  [useMyAddressButton setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y)];
                                  [useMyAddressButton setFrame:CGRectMake(useMyAddressButton.frame.origin.x, useSuggestedAddressButton.frame.origin.y + useSuggestedAddressButton.frame.size.height + PADDING, useMyAddressButton.frame.size.width, useMyAddressButton.frame.size.height)];
                                  [useMyAddressButton addTarget:self action:@selector(saveWithEnteredAddress:) forControlEvents:UIControlEventTouchUpInside];
                              }
                              useMyAddressButton.hidden = false;
                              
                              UIButton *reenterAddressButton = (UIButton *)[self.view viewWithTag:MAP_RE_ENTER_ADDRESS_BUTTON_IN_BLUR_VIEW_TAG];
                              if (!reenterAddressButton) {
                                  reenterAddressButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, useSuggestedAddressButton.frame.size.width, useSuggestedAddressButton.frame.size.height)];
                                  reenterAddressButton.tag = MAP_RE_ENTER_ADDRESS_BUTTON_IN_BLUR_VIEW_TAG;
                                  [self decorateButton:reenterAddressButton color:[ColorDefinition orangeColor]];
                                  [reenterAddressButton setTitle:@"I want to re-enter the address" forState:UIControlStateNormal];
                                  [self.blurView addSubview:reenterAddressButton];
                                  [reenterAddressButton setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y)];
                                  [reenterAddressButton setFrame:CGRectMake(reenterAddressButton.frame.origin.x, useMyAddressButton.frame.origin.y + useMyAddressButton.frame.size.height + PADDING, reenterAddressButton.frame.size.width, reenterAddressButton.frame.size.height)];
                                  [reenterAddressButton addTarget:self action:@selector(reenterClicked:) forControlEvents:UIControlEventTouchUpInside];
                              }
                              reenterAddressButton.hidden = false;
                              
                          }
         ];
    } else {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:RESULT_IMAGE_VIEW_IN_BLUR_VIEW_TAG];
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
            imageView.tag = RESULT_IMAGE_VIEW_IN_BLUR_VIEW_TAG;
            [self.blurView addSubview:imageView];
            [imageView setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
            [imageView setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y - 150)];
        }
        imageView.hidden = YES;
        
        UITextView *resultLabel = (UITextView *)[self.view viewWithTag:RESULT_LABEL_IN_BLUR_VIEW];
        if (!resultLabel) {
            resultLabel = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.blurView.frame.size.width - PADDING * 4, 50.0)];
            resultLabel.tag = RESULT_LABEL_IN_BLUR_VIEW;
            [resultLabel setFont:[UIFont boldSystemFontOfSize:12]];
            resultLabel.backgroundColor = [UIColor clearColor];
            [resultLabel setEditable:NO];
            [resultLabel setSelectable:NO];
            [self.blurView addSubview:resultLabel];
            [resultLabel setCenter:CGPointMake(imageView.center.x, imageView.center.y)];
            [resultLabel setFrame:CGRectMake(resultLabel.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + PADDING, resultLabel.frame.size.width, resultLabel.frame.size.height)];
        }
        resultLabel.text = @"Updating...";
        [resultLabel setTextAlignment:NSTextAlignmentCenter];
        resultLabel.hidden = false;
        
        [[RKObjectManager sharedManager] postObject:self.userObject path:@"user/update" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            imageView.hidden = NO;
            if(mappingResult.array != nil && [mappingResult.array count] > 0) {
                
                [imageView setImage:[UIImage imageNamed:@"No.png"]];
                [resultLabel setTextAlignment:NSTextAlignmentLeft];
                resultLabel.text = @"Sorry, we could not update your profile due to the following reason(s):";
                CGSize tvsize = [resultLabel sizeThatFits:CGSizeMake(resultLabel.frame.size.width, resultLabel.frame.size.height)];
                [resultLabel setFrame:CGRectMake(resultLabel.frame.origin.x, resultLabel.frame.origin.y, resultLabel.frame.size.width, tvsize.height)];
                
                UITextView *errorMessageView = (UITextView *)[self.view viewWithTag:RESULT_TEXT_VIEW_IN_BLUR_VIEW];
                if (!errorMessageView) {
                    errorMessageView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, resultLabel.frame.size.width, 50.0)];
                    errorMessageView.tag = RESULT_TEXT_VIEW_IN_BLUR_VIEW;
                    [self.blurView addSubview:errorMessageView];
                    [errorMessageView setFont:[UIFont systemFontOfSize:12]];
                    [errorMessageView setTextAlignment:NSTextAlignmentLeft];
                    errorMessageView.backgroundColor = [UIColor clearColor];
                    [errorMessageView setEditable:NO];
                    [errorMessageView setSelectable:NO];
                }
                errorMessageView.hidden = false;
                
                NSMutableString *errorMessage = [[NSMutableString alloc] init];
                for (RKErrorMessage *error in mappingResult.array) {
                    [errorMessage appendString:@" * "];
                    [errorMessage appendString:error.errorMessage];
                    [errorMessage appendString:@"\n"];
                }
                errorMessageView.text = errorMessage;
                tvsize = [errorMessageView sizeThatFits:CGSizeMake(resultLabel.frame.size.width, resultLabel.frame.size.height)];
                [errorMessageView setFrame:CGRectMake(resultLabel.frame.origin.x, resultLabel.frame.origin.y + resultLabel.frame.size.height + PADDING, resultLabel.frame.size.width, MIN(200.0,tvsize.height))];
                
                UIButton *okayButton = (UIButton *)[self.view viewWithTag:RESULT_OKAY_BUTTON_IN_BLUR_VIEW];
                if (!okayButton) {
                    okayButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 25.0)];
                    okayButton.tag = RESULT_OKAY_BUTTON_IN_BLUR_VIEW;
                    [self decorateButton:okayButton color:[ColorDefinition blueColor]];
                    [okayButton setTitle:@"Got it" forState:UIControlStateNormal];
                    [self.blurView addSubview:okayButton];
                    [okayButton setCenter:CGPointMake(self.blurView.center.x, self.blurView.center.y)];
                    [okayButton setFrame:CGRectMake(okayButton.frame.origin.x, errorMessageView.frame.origin.y + errorMessageView.frame.size.height + PADDING, okayButton.frame.size.width, okayButton.frame.size.height)];
                    [okayButton addTarget:self action:@selector(reenterClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
                okayButton.hidden = false;
                
                [self.navigationItem.leftBarButtonItem setEnabled:YES];
            } else {
                [imageView setImage:[UIImage imageNamed:@"Yes.png"]];
                resultLabel.text = @"Successfully updated profile.";
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(cancel:) userInfo:nil repeats:YES];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to save post: %@", error.localizedRecoverySuggestion);
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
        }];
    }
}

- (void)mapLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        MKMapView * mapView = (MKMapView *)[self.view viewWithTag:MAP_VIEW_IN_BLUR_VIEW_TAG];
        CGPoint touchLocation = [gestureRecognizer locationInView:mapView];
        
        CLLocationCoordinate2D coordinate = [mapView convertPoint:touchLocation toCoordinateFromView:mapView];
        self.userObject.latitude = [NSNumber numberWithDouble:coordinate.latitude];
        self.userObject.longitude = [NSNumber numberWithDouble:coordinate.longitude];
        for (id<MKAnnotation> annotation in mapView.annotations) {
            [mapView removeAnnotation:annotation];
        }
        [mapView addAnnotation:self.userObject];
    }
}

- (void) decorateButton:(UIButton *) button color:(UIColor *) color {
    button.layer.cornerRadius = 5;
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
}

- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) saveWithSuggestedAddress: (id) sender {
    [self.userObject updateAddress:self.suggestedAddress];
    self.addressChanged = false;
    [self save:self];
}

- (IBAction) saveWithEnteredAddress: (id) sender {
    self.addressChanged = false;
    [self save:self];
}

- (IBAction) reenterClicked: (id) sender {
    [self.table reloadData];
    [self.blurView removeFromSuperview];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}


@end
