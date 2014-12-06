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
#import "WLTinyURL.h"
#import "ImageUtil.h"

#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#

@interface AddWeedViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate, WeedAddingToolbarDelegate, WeedAddingImageViewDelegate>

@property (retain, nonatomic) UITextView *weedContentView;

@property (nonatomic, retain) UITableView *userList;

@property (nonatomic) BOOL hasEdited;

@property (nonatomic, retain) WeedAddingToolbar *toolbar;

@property (nonatomic, retain) UIImage *pickedImage;

@property (nonatomic, retain) WeedAddingImageView *pickImageView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, retain) UICollectionView *imageCollectionView;

@property (nonatomic, weak) UIPanGestureRecognizer *pan;

@property (nonatomic, strong) NSMutableDictionary * mentionedUsernameToUser;

@property (nonatomic, retain) UILabel *placeHolder;

@property (strong) NSArray *users;

@end

@implementation AddWeedViewController

static NSString * USER_TABLE_CELL_REUSE_ID = @"UserTableCell";

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    self.weedContentView = [[UITextView alloc] initWithFrame:CGRectMake(0, statusBarSize.height + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.weedContentView setFont:[UIFont systemFontOfSize:14.0]];
    double lineHeight = self.weedContentView.font.lineHeight + 14;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.minimumLineHeight = lineHeight;
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                };
    self.weedContentView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attribute];
    
    self.weedContentView.keyboardType = UIKeyboardTypeTwitter;
    self.weedContentView.delegate = self;
    self.weedContentView.backgroundColor = [UIColor clearColor];
    self.weedContentView.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.weedContentView becomeFirstResponder];
    [self.view addSubview:self.weedContentView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Post it" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    if (self.lightWeed != nil) {
        self.weedContentView.text = [NSString stringWithFormat:@"@%@ %@", self.lightWeed.username, self.weedContentView.text] ;
    } else {
        _hasEdited = NO;
        
        _placeHolder = [[UILabel alloc]initWithFrame:CGRectMake(6, self.weedContentView.frame.origin.y, 200, lineHeight)];
        _placeHolder.text = @"Share the moment...";
        _placeHolder.font = self.weedContentView.font;
        _placeHolder.textColor = [UIColor lightGrayColor];
        [self.view addSubview:_placeHolder];
    }
    
    double userListY = self.weedContentView.frame.origin.y + lineHeight + (lineHeight - self.weedContentView.font.lineHeight)/2.0;
    self.userList = [[UITableView alloc] initWithFrame:CGRectMake(0, userListY, self.view.frame.size.width, self.view.frame.size.height - userListY)];
    self.userList.hidden = true;
    [self.userList setSeparatorInset:UIEdgeInsetsZero];
    self.userList.tableFooterView = [[UIView alloc] init];
    self.userList.delegate = self;
    self.userList.dataSource = self;
    [self.userList registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_TABLE_CELL_REUSE_ID];
    [self.view addSubview:self.userList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.toolbar = [[WeedAddingToolbar alloc]init];
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height - self.toolbar.frame.size.height, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
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
    self.imageCollectionView.hidden = YES;
    self.dataArray = [[NSMutableArray alloc]initWithCapacity:9];
    
    [self.view bringSubviewToFront:self.userList];
    
    //create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.pan = pan;
    
    self.mentionedUsernameToUser = [[NSMutableDictionary alloc] init];
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.weedContentView.text.length == 0) {
        _hasEdited = NO;
        _placeHolder.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (!_hasEdited) {
        _placeHolder.hidden = YES;
        _hasEdited = YES;
    }
    
    //make sure mentions map in sync with text, so if user removed any mention, we need to remove it from mentions
    NSArray * tokens = [textView.text componentsSeparatedByCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableSet * validMentions = [[NSMutableSet alloc] init];
    for (NSString * token in tokens) {
        if([token hasPrefix:@"@"]){
            [validMentions addObject:token];
        }
    }
    for(NSString *username in self.mentionedUsernameToUser.allKeys) {
        if (![validMentions containsObject:[NSString stringWithFormat:@"%@", username]]) {
            [self.mentionedUsernameToUser removeObjectForKey:username];
        }
    }
}

- (void) adjustWeedContentView:(bool) hidden {
    if (self.userList.hidden == false) {
        if(hidden) {
            [self.weedContentView setContentOffset:CGPointMake(0.0 , self.weedContentView.contentInset.top) animated:NO];
            UIEdgeInsets weedContentViewContentInsets = UIEdgeInsetsMake(self.weedContentView.contentInset.top, 0.0, 0.0, 0.0);
            self.weedContentView.contentInset = weedContentViewContentInsets;
            self.weedContentView.scrollIndicatorInsets = weedContentViewContentInsets;
            self.userList.hidden = true;
        }
    } else {
        if(!hidden) {
            UIEdgeInsets weedContentViewContentInsets = UIEdgeInsetsMake(self.weedContentView.contentInset.top, 0.0, self.weedContentView.frame.origin.y + self.weedContentView.frame.size.height - self.userList.frame.origin.y, 0.0);
            self.weedContentView.contentInset = weedContentViewContentInsets;
            self.weedContentView.scrollIndicatorInsets = weedContentViewContentInsets;
            CGRect rect = [self.weedContentView caretRectForPosition:self.weedContentView.selectedTextRange.end];
            rect.size.height += self.weedContentView.textContainerInset.bottom;
            [self.weedContentView scrollRectToVisible:rect animated:true];
            self.userList.hidden = false;
        }
    }
}

- (void) adjustWeedContentViewContentInset
{
    [self.weedContentView setFrame:CGRectMake(self.weedContentView.frame.origin.x, self.weedContentView.frame.origin.y, self.weedContentView.frame.size.width, (self.imageCollectionView.hidden?self.toolbar.frame.origin.y:self.imageCollectionView.frame.origin.y) - self.weedContentView.frame.origin.y - 5/*padding*/)];
    CGPoint bottomOffset = CGPointMake(0, self.weedContentView.contentSize.height - self.weedContentView.bounds.size.height);
    if (bottomOffset.y > 0) {
        [self.weedContentView setContentOffset:bottomOffset animated:YES];
        [self.weedContentView setSelectedRange:NSMakeRange(self.weedContentView.text.length, 0)];
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
    
    self.toolbar.center = CGPointMake(self.toolbar.bounds.size.width / 2, kbPosition.y - (self.toolbar.bounds.size.height / 2));
    self.imageCollectionView.center = CGPointMake(self.toolbar.center.x, self.toolbar.center.y - (self.toolbar.bounds.size.height / 2) - (self.imageCollectionView.bounds.size.height / 2));
    
    [self adjustWeedContentViewContentInset];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.userList.contentInset = contentInsets;
    self.userList.scrollIndicatorInsets = contentInsets;
    self.toolbar.center = CGPointMake(self.toolbar.bounds.size.width / 2, self.view.superview.bounds.size.height - (self.toolbar.bounds.size.height / 2));
    self.imageCollectionView.center = CGPointMake(self.toolbar.center.x, self.toolbar.center.y - (self.toolbar.bounds.size.height / 2) - (self.imageCollectionView.bounds.size.height / 2));
    [self adjustWeedContentViewContentInset];
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
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
    if (cell) {
        User *user = [self.users objectAtIndex:indexPath.row];
        [cell decorateCellWithUser:user];
        cell.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:0.4];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return USER_TABLE_VIEW_CELL_HEIGHT;
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
    [self.mentionedUsernameToUser setObject:user forKey:[NSString stringWithFormat:@"@%@", user.username]];
}

#pragma mark -
#pragma mark Save and Cancel
- (void) save: (id) sender {
    
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    Weed *weed = [NSEntityDescription insertNewObjectForEntityForName:@"Weed" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    weed.username = appDelegate.currentUser.username;
    weed.user_id = appDelegate.currentUser.id;
    if (self.lightWeed != nil) {
        weed.light_id = self.lightWeed.id;
        if (self.lightWeed.root_id != nil) {
            weed.root_id = self.lightWeed.root_id;
        } else {
            weed.root_id = weed.light_id;
        }
        User *lightWeedUser = [User new];
        lightWeedUser.id = self.lightWeed.user_id;
        lightWeedUser.username = self.lightWeed.username;
        [self.mentionedUsernameToUser setObject:lightWeedUser forKey:self.lightWeed.username];
    }
    weed.mentions = [[NSSet alloc] initWithArray:self.mentionedUsernameToUser.allValues];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    weed.content = self.weedContentView.text;
    weed.time = [NSDate date];
    weed.image_count = [NSNumber numberWithUnsignedInteger:self.dataArray.count];
    
    //Adding image metadata to the weed relationship
    NSMutableSet *images = [[NSMutableSet alloc]init];
    for (int i = 0; i < self.dataArray.count; i++) {
        WeedImage *weedImage = [NSEntityDescription insertNewObjectForEntityForName:@"WeedImage" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
        weedImage.imageId = [NSNumber numberWithInt:i];
        weedImage.width = [NSNumber numberWithFloat:((UIImage *)[self.dataArray objectAtIndex:i]).size.width];
        weedImage.height = [NSNumber numberWithFloat:((UIImage *)[self.dataArray objectAtIndex:i]).size.height];
        weedImage.parent = weed;
        [images addObject:weedImage];
    }
    weed.images = [[NSSet alloc] initWithArray:[images allObjects]];
    
    //Sending Request to Server
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:weed method:RKRequestMethodPOST path:@"weed/create" parameters:nil  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < self.dataArray.count; i++) {
            UIImage *image = [self.dataArray objectAtIndex:i];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0)
                                        name:[NSString stringWithFormat:@"%d", i]
                                    fileName:[NSString stringWithFormat:@"%d.jpeg", i]
                                    mimeType:@"image/jpeg"];
        }
    }];
    
    RKManagedObjectRequestOperation *operation = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request managedObjectContext:weed.managedObjectContext
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Create weed successed, Response: %@", mappingResult);
        weed.is_feed = [NSNumber numberWithInt:1];
        weed.sort_time = weed.time;
        NSError *error = nil;
        BOOL successful = [weed.managedObjectContext save:&error];
        if (!successful) {
            NSLog(@"Save Weed Error: %@", error.localizedDescription);
        }
        if (self.lightWeed) {
            self.lightWeed.if_cur_user_light_it = [NSNumber numberWithInt:1];
            self.lightWeed.light_count = [NSNumber numberWithInt:[self.lightWeed.light_count intValue] + 1];
            successful = [self.lightWeed.managedObjectContext save:&error];
            if (!successful) {
                NSLog(@"Save Light Weed Error: %@", error.localizedDescription);
            }
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving post: %@", error.localizedDescription);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Weed Posting failed" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
    operation.targetObject = weed;
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cancel: (id) sender {
    if ([self.weedContentView isFirstResponder]) {
        [self.weedContentView resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressPickingPicture:(WeedAddingToolbar *)view
{
    if ([self isPhotosOverLimit]) {
        return;
    }
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)pressTakingPicture:(WeedAddingToolbar *)view
{
    if ([self isPhotosOverLimit]) {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (BOOL)isPhotosOverLimit
{
    if (self.dataArray.count >= 9) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Hey, Easy My friend, That's enough." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return YES;
    }
    
    return NO;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.imageCollectionView.hidden) {
        self.imageCollectionView.hidden = NO;
    }
    UIImage *compressedImage = [ImageUtil imageWithCompress:pickImage];
    if (!compressedImage) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Photo is too large!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else {
        [self.dataArray addObject: [ImageUtil generatePhotoThumbnail:compressedImage]];
        [self.imageCollectionView reloadData];
        [self.weedContentView becomeFirstResponder];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:[AppDelegate getUIStatusBarStyle]];
}

#pragma mark -- WeedAddingImageViewDelegate

- (void)pressDelete:(WeedAddingImageView *)view
{
    [self.dataArray removeObject:view.image];
    [self.imageCollectionView reloadData];
    if ([self.dataArray count] == 0) {
        self.imageCollectionView.hidden = true;
        [self adjustWeedContentViewContentInset];
    }
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
        cell.pickImageView.allowFullScreenDisplay = YES;
        cell.pickImageView.contentMode = UIViewContentModeScaleAspectFill;
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

+(void) presentControllerFrom:(UIViewController*) controller withWeed:(Weed*) weed
{
    AddWeedViewController* viewController = [[AddWeedViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setLightWeed:weed];
    UINavigationController *nav = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
    [nav setViewControllers:[[NSArray alloc] initWithObjects:viewController, nil]];
    [controller presentViewController:nav animated:YES completion:nil];
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
