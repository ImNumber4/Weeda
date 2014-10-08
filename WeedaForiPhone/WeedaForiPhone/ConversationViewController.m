//
//  ConversationViewController.m
//  WeedaForiPhone
//
//  Created by LV on 9/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ConversationViewController.h"
#import "AppDelegate.h"
#import "WeedImageController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserTableViewCell.h"

@interface ConversationViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIImage *participant_avatar;
@property (nonatomic, strong) UIImage *current_user_avatar;

@property (nonatomic, retain) NSMutableArray *users;

@end

@implementation ConversationViewController

const NSInteger USER_LIST_TAG = 1;

#pragma mark - Initialization
- (UIButton *)sendButton
{
    // Override to use a custom send button
    // The button's frame is set automatically for you
    return [UIButton defaultSendButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    
    [self reloadView];
}

- (void) reloadView {
    if ([self isNewConversation]) {
        self.title = @"New Message";
        self.users = [NSMutableArray array];
        [self.view bringSubviewToFront:self.usernameTextField];
        [self.view bringSubviewToFront:self.usernameList];
        [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.usernameTextField becomeFirstResponder];
        self.usernameList.tag = USER_LIST_TAG;
        self.usernameList.hidden = true;
        [self.usernameList setSeparatorInset:UIEdgeInsetsZero];
        self.usernameList.tableFooterView = [[UIView alloc] init];
        self.usernameList.delegate = self;
        [self.usernameList setFrame:CGRectMake(self.usernameList.frame.origin.x, self.usernameList.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.usernameList.frame.origin.y)];
        self.inputToolBarView.hidden = true;
    } else {
        //init fetch controller
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
        fetchRequest.sortDescriptors = @[descriptor];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type = 'message' and (participant_id = %@)", self.participant_id]];
        fetchRequest.predicate = predicate;
        // Setup fetched results
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
        [self.fetchedResultsController setDelegate:self];
        
        
        UIImageView *avatar =  [[UIImageView alloc] init];
        [avatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:self.participant_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
        self.participant_avatar = avatar.image;
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [avatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:appDelegate.currentUser.id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
        self.current_user_avatar = avatar.image;
        
        self.inputToolBarView.hidden = false;
        self.title = self.participant_username;
        self.usernameTextField.hidden = true;
        self.usernameList.hidden = true;
        [self loadData];
        [self showConversation];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view sendSubviewToBack:self.usernameTextField];
    [self.view sendSubviewToBack:self.usernameList];
}

- (BOOL) isNewConversation
{
    return self.participant_id == nil || self.participant_username == nil;
}

#pragma mark - Username TextField delegate
- (void)textFieldDidChange:(UITextField *)textField
{
    self.usernameList.hidden = false;
    NSString *usernamePrefix = textField.text;
    if ([usernamePrefix isEqualToString:@""]) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getFollowingUsers/%@/%d",appDelegate.currentUser.id, 10] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self updateUsernameListWithMappingResult:mappingResult];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Load getFollowingUsers failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getUsernamesByPrefix/%@", usernamePrefix] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self updateUsernameListWithMappingResult:mappingResult];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Load getUsernamesByPrefix failed with error: %@", error);
        }];
    }
}

- (void) updateUsernameListWithMappingResult:(RKMappingResult *)mappingResult
{
    @synchronized (self) {
        [self.users removeAllObjects];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        for (User * user in mappingResult.array) {
            if (![user.id isEqualToNumber:appDelegate.currentUser.id]) {
                [self.users addObject:user];
            }
        }
        [self.usernameList reloadData];
    }
}

- (void)decorateCellWithUser:(User *)user cell:(UserTableViewCell *)cell {
    [cell.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user.id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    [cell.userAvatar setFrame:CGRectMake(5, 5, 40, 40)];
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", user.username];
    cell.usernameLabel.text = nameLabel;
}


- (void) loadData {
    NSError *error = nil;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch Error: %@",error);
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == USER_LIST_TAG) {
        return self.users.count;
    } else {
        id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == USER_LIST_TAG) {
        return 1;
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == USER_LIST_TAG) {
        return 50;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == USER_LIST_TAG) {
        UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableCell" forIndexPath:indexPath];
        User *user = [self.users objectAtIndex:indexPath.row];
        [self decorateCellWithUser:user cell:cell];
        cell.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:0.4];
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == USER_LIST_TAG) {
        [self.usernameTextField endEditing:true];
    } else {
        [super scrollViewDidScroll:scrollView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == USER_LIST_TAG) {
        [self.usernameTextField endEditing:true];
        User *user = [self.users objectAtIndex:indexPath.row];
        self.participant_username = user.username;
        self.participant_id = user.id;
        [self reloadView];
    }
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    self.sendButton.enabled = false;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    message.id = [NSNumber numberWithInt:-1];
    message.sender_id = appDelegate.currentUser.id;
    message.participant_id = self.participant_id;
    message.participant_username = self.participant_username;
    message.time = [NSDate date];
    message.type = MESSAGE_TYPE;
    message.is_read = [NSNumber numberWithInt:1];//to make it marked as read locally
    message.message = text;
    [self createMessageOnServer:message];
}

- (void) createMessageOnServer:(Message *) message {
    [[RKObjectManager sharedManager] postObject:message path:@"message/create" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadData];
        [self finishSend];
        self.sendButton.enabled = true;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving message: %@", error.localizedDescription);
        [[[RKObjectManager sharedManager] managedObjectStore].mainQueueManagedObjectContext deleteObject:message];
        self.sendButton.enabled = true;
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.currentUser.id isEqualToNumber:message.sender_id]) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        if ([message.is_read intValue] == 0) {
            [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"message/read/%@", message.id]  parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                message.is_read = [NSNumber numberWithInt:1];
                [[[RKObjectManager sharedManager] managedObjectStore].mainQueueManagedObjectContext refreshObject:message mergeChanges:YES];
                NSError *error = nil;
                [message.managedObjectContext save:&error];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                RKLogError(@"Failed to call message/read due to error: %@", error);
            }];
        }
        return JSBubbleMessageTypeIncoming;
    }
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleSquare;
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAlternating;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    return JSAvatarStyleCircle;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return message.message;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return message.time;
}

- (UIImage *)avatarImageForIncomingMessage
{
    
    return self.participant_avatar;
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return self.current_user_avatar;
}

@end
