//
//  UserViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "UserViewController.h"
#import "CropImageViewController.h"
#import "AppDelegate.h"
#import "WeedBasicTableViewCell.h"
#import "WeedImage.h"
#import "WeedTableViewCell.h"
#import "DetailViewController.h"
#import "VendorMKAnnotationView.h"
#import "WeedImageController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EditProfileViewController.h"
#import "ConversationViewController.h"
#import "UserListViewController.h"
#import "BlurView.h"
#import "UIViewHelper.h"
#import "ImageUtil.h"
#import "WLCoreDataHelper.h"

@interface UserViewController () <CropImageDelegate>

@property (nonatomic, retain) User *user;

@property (nonatomic, retain) NSMutableArray *weeds;

@property (nonatomic, retain) UIView *uploadAvatarView;
@property (nonatomic, retain) UIView *background;
@property (nonatomic, retain) UIButton *btnViewPhoto;
@property (nonatomic, retain) UIButton *btnTakePhoto;
@property (nonatomic, retain) UIButton *btnSelectFromLocal;
@property (nonatomic, retain) UIView *buttonContainerView;

@end

@implementation UserViewController

const NSInteger SHOW_FOLLOWERS = 1;
const NSInteger SHOW_FOLLOWINGS = 2;
static NSString *CELL_REUSE_ID = @"WeedTableCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([self.user_id isEqualToNumber:appDelegate.currentUser.id]) {
        UIImage * image = [UIImage imageNamed:@"setting.png"];
        CGSize sacleSize = CGSizeMake(30, 30);
        UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
        
        UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext() style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];
        [self.navigationItem setRightBarButtonItem:settingButton];
        self.userAvatarCamera.hidden = NO;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCameraTapped)]];
        self.userAvatar.userInteractionEnabled = YES;
        self.userAvatarCamera.image = [ImageUtil colorImage:[UIImage imageNamed:@"caremar.png"] color:[UIColor whiteColor]];
        self.userAvatarCamera.layer.shadowColor = [ColorDefinition greenColor].CGColor;
        self.userAvatarCamera.layer.shadowOffset = CGSizeMake(0, 1);
        self.userAvatarCamera.layer.shadowOpacity = 0.8;
        self.userAvatarCamera.layer.shadowRadius = 2.0;
        self.userAvatar.allowFullScreenDisplay = NO;
    } else {
        self.userAvatarCamera.hidden = YES;
        self.userAvatar.allowFullScreenDisplay = YES;
    }
    
    [self.followerCountLabel addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    self.followerCountLabel.tag = SHOW_FOLLOWERS;
    [self.followingCountLabel addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    self.followingCountLabel.tag = SHOW_FOLLOWINGS;
    
    [UIViewHelper roundCorners:self.followButton byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerTopLeft];
    [UIViewHelper roundCorners:self.messageButton byRoundingCorners:UIRectCornerBottomRight|UIRectCornerTopRight];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView registerClass:[WeedBasicTableViewCell class] forCellReuseIdentifier:CELL_REUSE_ID];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.weeds = [[NSMutableArray alloc] init];
    
    [self createUploadAvatarView];
    
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    
    //Add data change notification
    [WLCoreDataHelper addCoreDataChangedNotificationTo:self selecter:@selector(objectChangedNotificationReceived:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    
    //Get User Profile
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/query/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateUserAvatar];
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/query/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        [self.weeds removeAllObjects];
        for(Weed* weed in [mappingResult.array sortedArrayUsingDescriptors:descriptors]) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.weeds addObject:weed];
            }
        }
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"User";
    if ([annotation isKindOfClass:[User class]]) {
        VendorMKAnnotationView *annotationView = (VendorMKAnnotationView *) [self.location dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[VendorMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            
        } else {
            [annotationView setAnnotation:annotation];
        }
        [annotationView setSelected:YES animated:YES];
        [annotationView decorateWithAnnotation:annotation];
        return annotationView;
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weeds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WeedBasicTableViewCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeedBasicTableViewCell *cell = (WeedBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
    Weed *weed = [self.weeds objectAtIndex:indexPath.row];
    
    [self decorateCellWithWeed:weed cell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showWeed" sender:self];
}

- (void)decorateCellWithWeed:(Weed *)weed cell:(WeedBasicTableViewCell *)cell
{
    [cell decorateCellWithContent:weed.content username:weed.username time:weed.time user_id:weed.user_id user_type:nil/*make it to be nil on purpose, this view already has icon*/];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *userPickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CropImageViewController* viewController = [[CropImageViewController alloc] initWithNibName:nil bundle:nil];
    viewController.image = userPickedImage;
    viewController.enableImageCrop = YES;
    viewController.delegate = self;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:^{[self presentViewController:viewController animated:YES completion:nil];}];
    } else {
        [picker pushViewController:viewController animated:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:[AppDelegate getUIStatusBarStyle]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showUsers"]) {
        UserListViewController *controller = (UserListViewController *)[segue destinationViewController];
        NSString * feedUrl;
        if ([sender tag] == SHOW_FOLLOWERS) {
            feedUrl = [NSString stringWithFormat:@"user/getFollowers/%@/%d", self.user.id, 10];
            [controller setTitle:@"Followed by"];
        } else {
            feedUrl = [NSString stringWithFormat:@"user/getFollowingUsers/%@/%d", self.user.id, 10];
            [controller setTitle:@"Following"];
        }
        [controller setUrlPathToPullUsers:feedUrl];
    } else if ([[segue identifier] isEqualToString:@"showWeed"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Weed *weed = [self.weeds objectAtIndex:indexPath.row];
        [[segue destinationViewController] setCurrentWeed:weed];
    } else if ([[segue identifier] isEqualToString:@"editProfile"]) {
        UINavigationController* nav = [segue destinationViewController];
        EditProfileViewController* editProfileViewController = (EditProfileViewController *) nav.topViewController;
        [editProfileViewController setTitle:@"Edit Profile"];
        [editProfileViewController setUserObject:self.user];
    } else if ([[segue identifier] isEqualToString:@"messageUser"]) {
        ConversationViewController* controller = [segue destinationViewController];
        [controller setParticipant_id:self.user.id];
        [controller setParticipant_username:self.user.username];
    }
}

- (BOOL) uploadImageToServer:(UIImage *)image
{
    User *user = [User new];
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:user method:RKRequestMethodPOST path:@"user/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0)
                                    name:@"avatar"
                                fileName:@"avatar.jpeg"
                                mimeType:@"image/jpeg"];
    }];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Upload image success.");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    return YES;
}

- (void)setting:(id)sender
{
    [self performSegueWithIdentifier:@"editSettings" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeMessageButton:(BOOL)enabled
{
    [self.messageButton setTitle:@"Message" forState:UIControlStateNormal];
    self.messageButton.enabled = enabled;
    self.messageButton.backgroundColor = enabled ? [ColorDefinition orangeColor]:[ColorDefinition grayColor];
    [self.messageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    if(enabled)
        [self.messageButton addTarget:self action:@selector(message:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowButton
{
    [self.followButton setTitle:@"+Follow" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [ColorDefinition blueColor];
    [self.followButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.followButton addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton
{
    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [ColorDefinition greenColor];
    [self.followButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.followButton addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeEditProfileButton
{
    [self.followButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [ColorDefinition grayColor];
    [self.followButton addTarget:self action:@selector(editProfile:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateView
{
    self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"%@", self.user.username];
    if (self.user.userDescription && [self.user.userDescription length] > 0) {
        self.userDescription.text = self.user.userDescription;
    } else {
        self.userDescription.text = @"No description.";
    }
    
    CGRect tempFrame = CGRectMake(0, 0, self.userDescription.frame.size.width, 50);
    CGSize tvsize = [self.userDescription sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)];
    [self.userDescription setFrame:CGRectMake(self.userDescription.frame.origin.x, self.userDescription.frame.origin.y, self.userDescription.frame.size.width, tvsize.height)];
    [self.location setFrame:CGRectMake(self.location.frame.origin.x, self.userDescription.frame.origin.y + self.userDescription.frame.size.height + 5, self.userDescription.frame.size.width, self.location.frame.size.height)];
    
    double tableViewYCoordinate;
    if(![USER_TYPE_USER isEqualToString:self.user.user_type]) {
        self.location.hidden = NO;
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = self.user.latitude.doubleValue;
        zoomLocation.longitude= self.user.longitude.doubleValue + 0.002;//move the zoom location left a little bit so we can have the annotation callout in the middle
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 200, 200);
        [self.location setRegion:viewRegion animated:YES];
        for (id<MKAnnotation> annotation in self.location.annotations) {
            [self.location removeAnnotation:annotation];
        }
        [self.location addAnnotation:self.user];
        tableViewYCoordinate = self.location.frame.origin.y + self.location.frame.size.height + 5;
    } else {
        self.location.hidden = YES;
        tableViewYCoordinate = self.userDescription.frame.origin.y + self.userDescription.frame.size.height + 5;
    }
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, tableViewYCoordinate, self.tableView.frame.size.width, self.view.frame.size.height  -  self.tabBarController.tabBar.frame.size.height - tableViewYCoordinate)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.user.time];
    self.timeLabel.text = [NSString stringWithFormat:@"Memeber since: %@", formattedDateString];
    [self.weedCountLabel setTitle:[NSString stringWithFormat:@"%@", self.user.weedCount] forState:UIControlStateNormal];
    [self.followerCountLabel setTitle:[NSString stringWithFormat:@"%@", self.user.followerCount] forState:UIControlStateNormal];
    [self.followingCountLabel setTitle:[NSString stringWithFormat:@"%@", self.user.followingCount] forState:UIControlStateNormal];
    if ([self.user.relationshipWithCurrentUser intValue] == 0) {
        [self makeEditProfileButton];
        [self makeMessageButton:false];
    } else if ([self.user.relationshipWithCurrentUser intValue] < 3){
        [self makeFollowButton];
        [self makeMessageButton:true];
    } else {
        [self makeFollowingButton];
        [self makeMessageButton:true];
    }
}

-(void) showUsers:(id)sender {
    if (self.user) {
        [self performSegueWithIdentifier:@"showUsers" sender:sender];
    }
}

- (void)updateUserAvatar
{
    [self.userAvatar setImageURL:[WeedImageController imageURLOfAvatar:self.user_id] isAvatar:YES];
}

- (void)editProfile:(id)sender
{
    [self performSegueWithIdentifier:@"editProfile" sender:self];
}

- (void)follow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)unfollow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)message:(id)sender
{
    [self performSegueWithIdentifier:@"messageUser" sender:sender];
}

- (void)addItemViewContrller:(CropImageViewController *)controller didFinishCropImage:(UIImage *)cropedImage
{
    //Restore Image to SDWebImage cache
     [[SDImageCache sharedImageCache]storeImage:cropedImage forKey:[WeedImageController imageURLOfAvatar:self.user_id].absoluteString];
    
    //Upload Avatar to Server
    [self uploadImageToServer:cropedImage];
}

- (void)createUploadAvatarView
{
    _uploadAvatarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height)];
    _uploadAvatarView.backgroundColor = [UIColor clearColor];
    
    _background = [[UIView alloc]initWithFrame:_uploadAvatarView.frame];
    _background.backgroundColor = [UIColor grayColor];
    _background.alpha = 0.0;
    
    _buttonContainerView = [[UIView alloc]initWithFrame:CGRectMake(20, _uploadAvatarView.frame.size.height - 135, 280, 140)];
    
    CGFloat buttonHeight = 40;
    _btnViewPhoto = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _buttonContainerView.frame.size.width, buttonHeight)];
    _btnTakePhoto = [[UIButton alloc]initWithFrame:CGRectMake(0, buttonHeight + 5, _buttonContainerView.frame.size.width, buttonHeight)];
    _btnSelectFromLocal = [[UIButton alloc]initWithFrame:CGRectMake(0, buttonHeight * 2 + 5 * 2, _buttonContainerView.frame.size.width, buttonHeight)];
    
    [self formatButton:_btnViewPhoto title:@"View Photo"];
    [self formatButton:_btnTakePhoto title:@"Take Photo"];
    [self formatButton:_btnSelectFromLocal title:@"Select Exsiting Photo"];
    
    [_buttonContainerView addSubview:_btnViewPhoto];
    [_buttonContainerView addSubview:_btnTakePhoto];
    [_buttonContainerView addSubview:_btnSelectFromLocal];
    
    [_uploadAvatarView addSubview:_background];
    [_uploadAvatarView addSubview:_buttonContainerView];
    
    _uploadAvatarView.hidden = YES;
    [self.view addSubview:_uploadAvatarView];
    [self.view bringSubviewToFront:_uploadAvatarView];
    
    [_uploadAvatarView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCancelTap)]];
    [_btnViewPhoto addTarget:self action:@selector(handleViewPhotoHightlight:) forControlEvents:UIControlEventTouchDown];
    [_btnViewPhoto addTarget:self action:@selector(handleViewPhotoNormal:) forControlEvents:UIControlEventTouchUpInside];
    [_btnTakePhoto addTarget:self action:@selector(handleTakePhotoHightlight:) forControlEvents:UIControlEventTouchDown];
    [_btnTakePhoto addTarget:self action:@selector(handleTakePhotoNormal:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSelectFromLocal addTarget:self action:@selector(handleSelectPhotoHightlight:) forControlEvents:UIControlEventTouchDown];
    [_btnSelectFromLocal addTarget:self action:@selector(handleSelectPhotoNormal:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)formatButton:(UIButton *)button title:(NSString *)title
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[ColorDefinition greenColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[ColorDefinition greenColor].CGColor];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:7.0f];
}

- (void)handleCancelTap
{
    [UIView animateWithDuration:0.5 animations:^{
        _buttonContainerView.frame = CGRectMake(_buttonContainerView.frame.origin.x, _uploadAvatarView.frame.size.height, _buttonContainerView.frame.size.width, _buttonContainerView.frame.size.height);
        _background.alpha = 0.0f;
    }completion:^(BOOL finished) {
        _uploadAvatarView.hidden = YES;
    }];
}

- (void)handleViewPhotoHightlight:(id)sender
{
    _btnViewPhoto.backgroundColor = [ColorDefinition greenColor];
    [_btnViewPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)handleViewPhotoNormal:(id)sender
{
    _btnViewPhoto.backgroundColor = [UIColor whiteColor];
    [_btnViewPhoto setTitleColor:[ColorDefinition greenColor] forState:UIControlStateNormal];
    
    [self handleCancelTap];
    [self.userAvatar displayFullScreen];
}

- (void)handleTakePhotoHightlight:(id)sender
{
    _btnTakePhoto.backgroundColor = [ColorDefinition greenColor];
    [_btnTakePhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)handleTakePhotoNormal:(id)sender
{
    _btnTakePhoto.backgroundColor = [UIColor whiteColor];
    [_btnTakePhoto setTitleColor:[ColorDefinition greenColor] forState:UIControlStateNormal];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    [self handleCancelTap];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)handleSelectPhotoHightlight:(id)sender
{
    _btnSelectFromLocal.backgroundColor = [ColorDefinition greenColor];
    [_btnSelectFromLocal setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)handleSelectPhotoNormal:(id)sender
{
    _btnSelectFromLocal.backgroundColor = [UIColor whiteColor];
    [_btnSelectFromLocal setTitleColor:[ColorDefinition greenColor] forState:UIControlStateNormal];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    [self handleCancelTap];
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)handleCameraTapped
{
    _buttonContainerView.frame = CGRectMake(_buttonContainerView.frame.origin.x, _uploadAvatarView.frame.size.height, _buttonContainerView.frame.size.width, _buttonContainerView.frame.size.height);
    _uploadAvatarView.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        _buttonContainerView.frame = CGRectMake(_buttonContainerView.frame.origin.x, _uploadAvatarView.frame.size.height - 135, _buttonContainerView.frame.size.width, _buttonContainerView.frame.size.height);
        _background.alpha = 0.8;
    }];
}

#pragma mark - Notification receiver
- (void)objectChangedNotificationReceived:(NSNotification *)notification
{
    NSArray *deleteWeeds = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (Weed *weed in deleteWeeds) {
        if ([self.weeds containsObject:weed]) {
            NSUInteger row = [self.weeds indexOfObject:weed];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.weeds removeObject:weed];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        }
    }
}

@end
