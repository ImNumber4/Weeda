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

@interface ConversationViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIImage *participant_avatar;
@property (nonatomic, strong) UIImage *current_user_avatar;
@end

@implementation ConversationViewController

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
    
    self.title = self.participant_username;
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
    NSError *error = nil;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch Error: %@",error);
    }
    [self scrollToBottomAnimated:NO];
    UIImageView *avatar =  [[UIImageView alloc] init];
    [avatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:self.participant_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    self.participant_avatar = avatar.image;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [avatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:appDelegate.currentUser.id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    self.current_user_avatar = avatar.image;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
//    [self.messages addObject:text];
//    
//    [self.timestamps addObject:[NSDate date]];
//    
//    if((self.messages.count - 1) % 2)
//        [JSMessageSoundEffect playMessageSentSound];
//    else
//        [JSMessageSoundEffect playMessageReceivedSound];
//    
//    [self finishSend];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return ([appDelegate.currentUser.id isEqualToNumber:message.sender_id]) ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
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
