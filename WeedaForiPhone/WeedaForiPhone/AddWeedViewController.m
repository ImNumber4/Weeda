//
//  AddWeedViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//
#import "AppDelegate.h"
#import "AddWeedViewController.h"
#import "UserTableViewCell.h"
#import "WeedAddingToolbar.h"
#import "WeedAddingImageView.h"
#import "WeedAddingImageCell.h"
#import "WeedImage.h"
#import "WeedImageController.h"

#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AddWeedViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate, WeedAddingToolbarDelegate, WeedAddingImageViewDelegate>

@property (nonatomic, retain) WeedAddingToolbar *toolbar;

@property (nonatomic, retain) UIImage *pickedImage;

@property (nonatomic, retain) WeedAddingImageView *pickImageView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, retain) UICollectionView *imageCollectionView;

@property (nonatomic, weak) UIPanGestureRecognizer *pan;

@property (nonatomic, strong) NSMutableDictionary * mentionedUsernameToUserId;//

@end

@implementation AddWeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Weed it" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    if (self.lightWeed != nil) {
        self.weedContentView.text = [NSString stringWithFormat:@"@%@ %@", self.lightWeed.username, self.weedContentView.text] ;
    }
    self.weedContentView.delegate = self;
    [self.weedContentView becomeFirstResponder];
    self.userList.hidden = true;
    [self.userList setSeparatorInset:UIEdgeInsetsZero];
    self.userList.tableFooterView = [[UIView alloc] init];
    self.userList.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.toolbar = [[WeedAddingToolbar alloc]init];
    self.toolbar.delegate = self;
    [self.view addSubview:self.toolbar];
    [self.view bringSubviewToFront:self.toolbar];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 3;
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.imageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 320, 100) collectionViewLayout:layout];
    [self.imageCollectionView setDelegate:self];
    [self.imageCollectionView setDataSource:self];
    [self.imageCollectionView registerNib:[UINib nibWithNibName:@"WeedAddingImageCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    [self.imageCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.imageCollectionView];
    self.dataArray = [[NSMutableArray alloc]initWithCapacity:9];
    
    [self.view bringSubviewToFront:self.userList];
    
    //create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.pan = pan;
    
    self.mentionedUsernameToUserId = [[NSMutableDictionary alloc] init];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * textNeedToBeProcessed = [[textView.text substringToIndex:(range.length > 0 ? range.location : range.location - range.length)] stringByAppendingString:text];
    NSArray *allWords = [textNeedToBeProcessed componentsSeparatedByCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mostRecentWord = [allWords lastObject];
    
    if([mostRecentWord hasPrefix:@"@"]){
        NSString *usernamePrefix = [mostRecentWord substringFromIndex:1];
        if ([usernamePrefix isEqualToString:@""]) {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getFollowingUsers/%@/%d",appDelegate.currentUser.id, 10] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                self.users = mappingResult.array;
                [self.userList reloadData];
                [self adjustWeedContentView:false];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                RKLogError(@"Load getFollowingUsers failed with error: %@", error);
            }];
        } else {
            [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getUsernamesByPrefix/%@", usernamePrefix] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                self.users = mappingResult.array;
                [self.userList reloadData];
                [self adjustWeedContentView:false];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                RKLogError(@"Load getUsernamesByPrefix failed with error: %@", error);
            }];
        }
    }else{
        [self adjustWeedContentView:true];
    }
    return true;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //make sure mentions map in sync with text, so if user removed any mention, we need to remove it from mentions
    NSArray * tokens = [textView.text componentsSeparatedByCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableSet * validMentions = [[NSMutableSet alloc] init];
    for (NSString * token in tokens) {
        if([token hasPrefix:@"@"]){
            [validMentions addObject:token];
        }
    }
    for(NSString *key in self.mentionedUsernameToUserId.allKeys) {
        if (![validMentions containsObject:key]) {
            [self.mentionedUsernameToUserId removeObjectForKey:key];
        }
    }
}

- (void) adjustWeedContentView:(bool) hidden {
    if (self.userList.hidden == false) {
        if(hidden) {
            [self.weedContentView setContentOffset:CGPointMake(0.0 , self.weedContentView.contentInset.top) animated:NO];
            UIEdgeInsets weedContentViewContentInsets = UIEdgeInsetsMake(self.weedContentView.contentInset.top, 0.0, 218, 0.0);
            self.weedContentView.contentInset = weedContentViewContentInsets;
            self.weedContentView.scrollIndicatorInsets = weedContentViewContentInsets;
            self.userList.hidden = true;
        }
    } else {
        if(!hidden) {
            UITextRange *range = self.weedContentView.selectedTextRange;
            UITextPosition *position = range.start;
            CGRect cursorRect = [self.weedContentView caretRectForPosition:position];
            CGPoint cursorPoint = CGPointMake(self.weedContentView.frame.origin.x + cursorRect.origin.x, self.weedContentView.frame.origin.y + cursorRect.origin.y);
            [self.weedContentView setContentOffset:CGPointMake((cursorPoint.x - 10) * self.weedContentView.zoomScale, (cursorPoint.y - 10) * self.weedContentView.zoomScale) animated:NO];
            UIEdgeInsets weedContentViewContentInsets = UIEdgeInsetsMake(self.weedContentView.contentInset.top, 0.0, self.userList.bounds.size.height, 0.0);
            self.weedContentView.contentInset = weedContentViewContentInsets;
            self.weedContentView.scrollIndicatorInsets = weedContentViewContentInsets;
            self.userList.hidden = false;
        }
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect keyboardFrameInWindowsCoordinates;
    [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindowsCoordinates];
    CGPoint kbPosition = keyboardFrameInWindowsCoordinates.origin;
    CGSize kbSize = keyboardFrameInWindowsCoordinates.size;
    
    UIEdgeInsets userListContentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.userList.contentInset = userListContentInsets;
    self.userList.scrollIndicatorInsets = userListContentInsets;
    UIEdgeInsets weedContentViewContentInsets = UIEdgeInsetsMake(self.weedContentView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.weedContentView.contentInset = weedContentViewContentInsets;
    self.weedContentView.scrollIndicatorInsets = weedContentViewContentInsets;
    
    self.toolbar.center = CGPointMake(self.toolbar.bounds.size.width / 2, kbPosition.y - (self.toolbar.bounds.size.height / 2));
    self.imageCollectionView.center = CGPointMake(self.toolbar.center.x, self.toolbar.center.y - (self.toolbar.bounds.size.height / 2) - (self.imageCollectionView.bounds.size.height / 2));
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.userList.contentInset = contentInsets;
    self.userList.scrollIndicatorInsets = contentInsets;
    self.toolbar.center = CGPointMake(self.toolbar.bounds.size.width / 2, self.view.superview.bounds.size.height - (self.toolbar.bounds.size.height / 2));
    self.imageCollectionView.center = CGPointMake(self.toolbar.center.x, self.toolbar.center.y - (self.toolbar.bounds.size.height / 2) - (self.imageCollectionView.bounds.size.height / 2));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableCell" forIndexPath:indexPath];
    User *user = [self.users objectAtIndex:indexPath.row];
    [self decorateCellWithUser:user cell:cell];
    cell.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:0.4];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.users objectAtIndex:indexPath.row];
    NSRange cursorPosition = [self.weedContentView selectedRange];
    NSString * textBeforeInsertionPoint = [[self.weedContentView text] substringToIndex:cursorPosition.location];
    NSString * textAfterInsertionPoint = [[self.weedContentView text] substringFromIndex:cursorPosition.location];
    NSRange lastAtCharacter = [textBeforeInsertionPoint rangeOfString:@"@" options:NSBackwardsSearch];
    self.weedContentView.text = [NSString stringWithFormat:@"%@%@ %@", [textBeforeInsertionPoint substringToIndex:lastAtCharacter.location + 1], user.username, textAfterInsertionPoint];
    [self.weedContentView setSelectedRange:NSMakeRange(self.weedContentView.text.length - textAfterInsertionPoint.length, 0)];
    [self adjustWeedContentView:true];
    [self.mentionedUsernameToUserId setObject:user.id forKey:[NSString stringWithFormat:@"@%@", user.username]];
}

- (void)decorateCellWithUser:(User *)user cell:(UserTableViewCell *)cell {
    [cell.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user.id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    cell.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    cell.userAvatar.clipsToBounds = YES;
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", user.username];
    cell.usernameLabel.text = nameLabel;
}

#pragma mark -
#pragma mark Save and Cancel
- (IBAction) save: (id) sender {
    
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    Weed *weed = [NSEntityDescription insertNewObjectForEntityForName:@"Weed" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    weed.id = [NSNumber numberWithInt:-1];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    weed.username = appDelegate.currentUser.username;
    weed.user_id = appDelegate.currentUser.id;
    weed.mentions = [[NSSet alloc] initWithArray:self.mentionedUsernameToUserId.allValues];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    weed.content = self.weedContentView.text;
    weed.time = [NSDate date];
    weed.image_count = [NSNumber numberWithUnsignedInteger:self.dataArray.count];
    if (self.lightWeed != nil) {
        weed.light_id = self.lightWeed.id;
        if (self.lightWeed.root_id != nil) {
            weed.root_id = self.lightWeed.root_id;
        } else {
            weed.root_id = weed.light_id;
        }
    }
    
    //Sending Request to Server
    [[RKObjectManager sharedManager] postObject:weed path:@"weed/create" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Response: %@", mappingResult);
        Weed *newWeed = mappingResult.firstObject;
        weed.id = newWeed.id;
        
        //Adding image metadata to the weed relationship
        NSMutableSet *images = [[NSMutableSet alloc]init];
        for (int i = 0; i < self.dataArray.count; i++) {
            WeedImage *weedImage = [NSEntityDescription insertNewObjectForEntityForName:@"WeedImage" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
            weedImage.url = [WeedImageController imageRelatedURLWithWeed:weed count:[NSNumber numberWithInt:i]];
            weedImage.width = [NSNumber numberWithFloat:((UIImage *)[self.dataArray objectAtIndex:i]).size.width];
            weedImage.height = [NSNumber numberWithFloat:((UIImage *)[self.dataArray objectAtIndex:i]).size.height];
            [images addObject:weedImage];
        }
        weed.images = images;

        
        if (self.dataArray.count > 0) {
            [self uploadImageToServer:weed];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving post: %@", error.localizedDescription);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadImageToServer:(Weed *)weed
{
    for (int i = 0; i < self.dataArray.count; i++) {
        UIImage * image = (UIImage *)[self.dataArray objectAtIndex:i];
        [[SDImageCache sharedImageCache] storeImage:image forKey:[[WeedImageController imageURLOfWeedId:weed.id userId:weed.user_id count:i] absoluteString] toDisk:NO];
        
        NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:[NSString stringWithFormat:@"weed/upload/%@", weed.id] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 100)
                                        name:@"image"
                                    fileName:[NSString stringWithFormat:@"%d.jpeg", i]
                                    mimeType:@"image/jpeg"];
        }];
        
        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Uploading image failed. url:%@, error: %@", weed.id, error);
        }];
        
        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    }
}

- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressPickingPicture:(WeedAddingToolbar *)view
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)pressTakingPicture:(WeedAddingToolbar *)view
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.dataArray addObject: [self generatePhotoThumbnail:pickImage]];
    [self.imageCollectionView reloadData];
    
    [self.weedContentView becomeFirstResponder];
}

#pragma mark -- WeedAddingImageViewDelegate

- (void)pressDelete:(WeedAddingImageView *)view
{
    [self.dataArray removeObject:view.image];
    [self.imageCollectionView reloadData];
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (WeedAddingImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeedAddingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    if (cell) {
        cell.pickImageView.image = [self.dataArray objectAtIndex:indexPath.item];
        cell.pickImageView.delegate = self;
    }
    return cell;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint horizontal = [gesture velocityInView:self.view];
    if (horizontal.y > 0) {
        [self.weedContentView endEditing:YES];
    }
}

- (UIImage *)generatePhotoThumbnail:(UIImage *)image
{
    //int kMaxResolution = 320;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    /*if (width > kMaxResolution || height > kMaxResolution)
     {
     CGFloat ratio = width/height;
     if (ratio > 1)
     {
     bounds.size.width = kMaxResolution;
     bounds.size.height = bounds.size.width / ratio;
     }
     else
     {
     bounds.size.height = kMaxResolution;
     bounds.size.width = bounds.size.height * ratio;
     }
     } */
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    
    return imageCopy;
    
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

@end
