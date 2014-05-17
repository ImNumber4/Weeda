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

@interface UserViewController () <CropImageDelegate>

@property (nonatomic, retain) User *user;

@property (nonatomic, retain) UIImage *userPickedImage;

@end

@implementation UserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.user.time];
    self.timeLabel.text = [NSString stringWithFormat:@"Memeber since: %@", formattedDateString];
    self.weedCountLabel.text = [NSString stringWithFormat:@"%@", self.user.weedCount];
    self.followerCountLabel.text = [NSString stringWithFormat:@"%@", self.user.followerCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%@", self.user.followingCount];
    if ([self.user.relationshipWithCurrentUser intValue] == 0) {
        [self makeEditProfileButton];
    } else if ([self.user.relationshipWithCurrentUser intValue] < 3){
        [self makeFollowButton];
    } else {
        [self makeFollowingButton];
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
