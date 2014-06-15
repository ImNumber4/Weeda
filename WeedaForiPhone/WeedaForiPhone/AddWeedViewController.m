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
#import <RestKit/RestKit.h>

@interface AddWeedViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

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
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSRange spaceRange = [[textView text] rangeOfString:@" " options:NSBackwardsSearch];
    NSRange lineBreakRange = [[textView text] rangeOfString:@"\n" options:NSBackwardsSearch];
    int lastSpaceIndex = (int)spaceRange.location;
    if (lastSpaceIndex == NSNotFound) {
        lastSpaceIndex = -1;
    }
    int lastLineBreakIndex = (int)lineBreakRange.location;
    if (lastLineBreakIndex == NSNotFound) {
        lastLineBreakIndex = -1;
    }
    NSString *separator = (lastSpaceIndex > lastLineBreakIndex)?@" ":@"\n";
    
    NSArray *allWords = [[textView text] componentsSeparatedByString: separator];
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
    CGSize kbSize = keyboardFrameInWindowsCoordinates.size;
    
    UIEdgeInsets userListContentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.userList.contentInset = userListContentInsets;
    self.userList.scrollIndicatorInsets = userListContentInsets;
    UIEdgeInsets weedContentViewContentInsets = UIEdgeInsetsMake(self.weedContentView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.weedContentView.contentInset = weedContentViewContentInsets;
    self.weedContentView.scrollIndicatorInsets = weedContentViewContentInsets;
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.userList.contentInset = contentInsets;
    self.userList.scrollIndicatorInsets = contentInsets;
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
    NSLog(@"%@", user.username);
    NSRange lastAtCharacter = [[self.weedContentView text] rangeOfString:@"@" options:NSBackwardsSearch];
    self.weedContentView.text = [NSString stringWithFormat:@"%@%@ ", [self.weedContentView.text substringToIndex:lastAtCharacter.location + 1], user.username];
    [self adjustWeedContentView:true];
}

- (void)decorateCellWithUser:(User *)user cell:(UserTableViewCell *)cell {
    cell.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:2.0];
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
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    weed.content = self.weedContentView.text;
    weed.time = [NSDate date];
    if (self.lightWeed != nil) {
        weed.light_id = self.lightWeed.id;
        if (self.lightWeed.root_id != nil) {
            weed.root_id = self.lightWeed.root_id;
        } else {
            weed.root_id = weed.light_id;
        }
    }
    
    [[RKObjectManager sharedManager] postObject:weed path:@"weed/create" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Response: %@", mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving post: %@", error.localizedDescription);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
