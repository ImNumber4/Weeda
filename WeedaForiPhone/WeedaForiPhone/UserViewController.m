//
//  UserViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "UserViewController.h"
#import "LoginViewController.h"
#import "CropImageViewController.h"
#import "AppDelegate.h"
#import "Image.h"
#import "WeedTableViewCell.h"
#import "DetailViewController.h"

@interface UserViewController () <CropImageDelegate>

@property (nonatomic, retain) User *user;

@property (nonatomic, retain) UIImage *userPickedImage;

@property (nonatomic, retain) NSMutableArray *weeds;

@end

@implementation UserViewController

const NSInteger SHOW_FOLLOWERS = 1;
const NSInteger SHOW_FOLLOWINGS = 2;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    
    //Get User Profile
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/query/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateView];
        
        //Get User Avatar
        [self getAvatarFromServer];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([self.user_id isEqualToNumber:appDelegate.currentUser.id]) {
        UIImage * image = [UIImage imageNamed:@"setting.png"];
        CGSize sacleSize = CGSizeMake(30, 30);
        UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
        
        UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext() style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];
        [self.navigationItem setRightBarButtonItem:settingButton];
        
    }
    
    [self.followerCountLabel addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    self.followerCountLabel.tag = SHOW_FOLLOWERS;
    [self.followingCountLabel addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    self.followingCountLabel.tag = SHOW_FOLLOWINGS;
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/query/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        self.weeds = [[NSMutableArray alloc] init];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeedTableCell";
    WeedTableViewCell *cell = (WeedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Weed *weed = [self.weeds objectAtIndex:indexPath.row];
    
    [self decorateCellWithWeed:weed cell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    Weed *weed = [self.weeds objectAtIndex:indexPath.row];
    
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:12.0];
    temp.text = weed.content;
    
    CGFloat textViewWidth = 200.0;
    CGRect tempFrame = CGRectMake(0, 0, textViewWidth, 50); //The height of this frame doesn't matter.
    CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.
    
    //Add the height of the other UI elements inside your cell
    return MAX(tvsize.height, 50.0) + 20.0;
}

- (void)decorateCellWithWeed:(Weed *)weed cell:(WeedTableViewCell *)cell
{
    [cell decorateCellWithWeed:weed];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/avatar/%@", weed.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (mappingResult.array.count > 0) {
            Image *image = [mappingResult.array objectAtIndex:0];
            [cell.userAvatar setImage:image.image];
            CALayer * l = [cell.userAvatar layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:7.0];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    }];
}

- (IBAction)handleSelectAvatar:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.userPickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self performSegueWithIdentifier:@"cropImage" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"cropImage"]) {
        UINavigationController *nav = [segue destinationViewController];
        CropImageViewController *view = (CropImageViewController *)[nav topViewController];
        view.image = self.userPickedImage;
        view.delegate = self;
    } else if([[segue identifier] isEqualToString:@"showUsers"]) {
        if ([sender tag] == SHOW_FOLLOWERS) {
            [[segue destinationViewController] setTitle:@"Followed by"];
        } else {
            [[segue destinationViewController] setTitle:@"Following"];
        }
        [[segue destinationViewController] setUsers:self.users];
    } else if ([[segue identifier] isEqualToString:@"showWeed"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Weed *weed = [self.weeds objectAtIndex:indexPath.row];
        [[segue destinationViewController] setCurrentWeed:weed];
    }
}

- (void) getAvatarFromServer
{
    if (self.user.hasAvatar == 0) {
        [self updateUserAvatar:nil];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/avatar/%@", self.user.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"Update User Avatar...");
            Image *image = [mappingResult.array objectAtIndex:0];
            [self updateUserAvatar:image.image];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Get Avatar Failed: %@", error);
        }];
    }
}

- (BOOL) uploadImageToServer:(UIImage *)image
{
    User *user = [User new];
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:user method:RKRequestMethodPOST path:@"user/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 90)
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
    // Dispose of any resources that can be recreated.
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeFollowButton
{
    [self.followButton setTitle:@"+Follow" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [UIColor colorWithRed:105.0/255.0 green:210.0/255.0 blue:245.0/255.0 alpha:1];
    [self.followButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.followButton addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton
{
    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:165.0/255.0 blue:64.0/255.0 alpha:1];
    [self.followButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.followButton addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeEditProfileButton
{
    [self.followButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
    [self.followButton addTarget:self action:@selector(editProfile:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateView
{
    self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"%@", self.user.username];
    self.description.text = self.user.description;
    CGRect tempFrame = CGRectMake(0, 0, self.description.frame.size.width, 50);
    CGSize tvsize = [self.description sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)];
    [self.description setFrame:CGRectMake(self.description.frame.origin.x, self.description.frame.origin.y, self.description.frame.size.width, tvsize.height)];
    [self.location setFrame:CGRectMake(self.location.frame.origin.x, self.description.frame.origin.y + self.description.frame.size.height + 5, self.description.frame.size.width, self.location.frame.size.height)];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.user.latitude.doubleValue;
    zoomLocation.longitude= self.user.longitude.doubleValue;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 3000, 3000);
    [self.location setRegion:viewRegion animated:YES];
    
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.location.frame.origin.y + self.location.frame.size.height + 5, self.location.frame.size.width, self.tableView.frame.size.height)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.user.time];
    self.timeLabel.text = [NSString stringWithFormat:@"Memeber since: %@", formattedDateString];
    [self.weedCountLabel setTitle:[NSString stringWithFormat:@"%@", self.user.weedCount] forState:UIControlStateNormal];
    [self.followerCountLabel setTitle:[NSString stringWithFormat:@"%@", self.user.followerCount] forState:UIControlStateNormal];
    [self.followingCountLabel setTitle:[NSString stringWithFormat:@"%@", self.user.followingCount] forState:UIControlStateNormal];
    if ([self.user.relationshipWithCurrentUser intValue] == 0) {
        [self makeEditProfileButton];
    } else if ([self.user.relationshipWithCurrentUser intValue] < 3){
        [self makeFollowButton];
    } else {
        [self makeFollowingButton];
    }
}

-(void) showUsers:(id)sender {
    if (self.user) {
        NSString * feedUrl;
        if ([sender tag] == SHOW_FOLLOWERS) {
            feedUrl = [NSString stringWithFormat:@"user/getFollowers/%@/%d", self.user.id, 10];
        } else {
            feedUrl = [NSString stringWithFormat:@"user/getFollowingUsers/%@/%d", self.user.id, 10];
        }
        [[RKObjectManager sharedManager] getObjectsAtPath:feedUrl parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            self.users = mappingResult.array;
            [self performSegueWithIdentifier:@"showUsers" sender:sender];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Load failed with error: %@", error);
        }];
    }
}

- (void)updateUserAvatar:(UIImage *)image
{
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    
    if (!image) {
        self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    } else {
        self.userAvatar.image = image;
    }
    
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

- (void)editProfile:(id)sender
{
    NSLog(@"Editing Profile");
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

- (void)addItemViewContrller:(CropImageViewController *)controller didFinishCropImage:(UIImage *)cropedImage
{
    //Upload Avatar to Server
    [self uploadImageToServer:cropedImage];
    
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    self.userAvatar.image = cropedImage;
}

@end
