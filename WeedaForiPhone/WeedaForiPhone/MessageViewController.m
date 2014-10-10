//
//  MessageViewController.m
//  WeedaForiPhone
//
//  Created by LV on 9/4/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "MessageViewController.h"
#import "WeedBasicTableViewCell.h"
#import "DetailViewController.h"
#import "ConversationViewController.h"

#define RED_DOT_RADIUS 4
#define RED_DOT_PAD 10.0

@interface MessageViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, WeedBasicTableViewCellDelegate>

@property (nonatomic, strong) NSFetchedResultsController *notificationFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *messageFetchedResultsController;
@property (nonatomic, retain) Weed *relatedWeedToShow; //use this to cache the weed user want to see before segue
@property (nonatomic, retain) NSMutableArray* conversations;
@property (nonatomic, retain) UIView* redDotForNotifications;
@property (nonatomic, retain) UIView* redDotForMessages;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversations = [[NSMutableArray alloc] init];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    CGFloat customRefreshControlHeight = 50.0f;
    CGFloat customRefreshControlWidth = 100.0;
    CGRect customRefreshControlFrame = CGRectMake(0.0f,
                                                  -customRefreshControlHeight,
                                                  customRefreshControlWidth,
                                                  customRefreshControlHeight);
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:customRefreshControlFrame];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];

    
    self.notificationFetchedResultsController = [self createNSFetchedResultsController:NOTIFICATION_TYPE sectionNameKeyPath:nil];
    self.messageFetchedResultsController = [self createNSFetchedResultsController:MESSAGE_TYPE sectionNameKeyPath:@"participant_id"];
    
    [self.segmentedControl addTarget:self action:@selector(segmentSwitched:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[self getImage:@"compose.png" width:30 height:30] style:UIBarButtonItemStylePlain target:self action:@selector(startNewConversation:)];
    [self.navigationItem setRightBarButtonItem:composeButton];
    
    [self initRedDotViews];
}

-(void)startNewConversation:(id)sender {
    [self performSegueWithIdentifier:@"newMessage" sender:self];
}

- (UIImage *)getImage:(NSString *)imageName width:(int)width height:(int) height
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void) initRedDotViews
{
    self.redDotForMessages = [self circleWithColor:self.segmentedControl.tintColor radius:RED_DOT_RADIUS];
    [self.segmentedControl addSubview:self.redDotForMessages];
    [self.segmentedControl bringSubviewToFront:self.redDotForMessages];
    [self.redDotForMessages setFrame:CGRectMake(self.segmentedControl.frame.size.width - RED_DOT_PAD  - RED_DOT_RADIUS * 2.0, self.segmentedControl.frame.size.height/2.0 - RED_DOT_RADIUS, self.redDotForMessages.frame.size.width, self.redDotForMessages.frame.size.height)];
    self.redDotForMessages.hidden = true;
    
    self.redDotForNotifications = [self circleWithColor:self.segmentedControl.tintColor radius:RED_DOT_RADIUS];
    [self.segmentedControl addSubview:self.redDotForNotifications];
    [self.segmentedControl bringSubviewToFront:self.redDotForNotifications];
    [self.redDotForNotifications setFrame:CGRectMake(self.segmentedControl.frame.size.width/2.0 - RED_DOT_PAD - RED_DOT_RADIUS * 2.0, self.segmentedControl.frame.size.height/2.0 - RED_DOT_RADIUS, self.redDotForNotifications.frame.size.width, self.redDotForNotifications.frame.size.height)];
    self.redDotForNotifications.hidden = true;
}

- (UIView *)circleWithColor:(UIColor *)color radius:(int)radius {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * radius, 2 * radius)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.layer.masksToBounds = YES;
    return circle;
}

- (NSFetchedResultsController *) createNSFetchedResultsController:(NSString *) type sectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    if (sectionNameKeyPath != nil) {
         NSSortDescriptor *sectionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sectionNameKeyPath ascending:NO];
        fetchRequest.sortDescriptors = @[sectionSortDescriptor, timeSortDescriptor];
    } else {
        fetchRequest.sortDescriptors = @[timeSortDescriptor];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type = '%@'", type]];
    fetchRequest.predicate = predicate;
    // Setup fetched results
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                    managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                                      sectionNameKeyPath:sectionNameKeyPath
                                                                                               cacheName:nil];
    
    [fetchedResultsController setDelegate:self];
    return fetchedResultsController;
}

- (NSFetchedResultsController *) getNSFetchedResultsController
{
    if ([self isRetrievingConversations]) {
        return self.messageFetchedResultsController;
    } else {
        return self.notificationFetchedResultsController;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fetachData];
}

-(void)segmentSwitched:(UISegmentedControl *)seg{
    [self loadData];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self fetachData];
}

- (void)fetachData
{
    // Load the object model via RestKit
    [[RKObjectManager sharedManager] getObjectsAtPath:@"message/query" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.redDotForNotifications.hidden = true;
        self.redDotForMessages.hidden = true;
        for (Message * message in mappingResult.array) {
            
            if ([message.type isEqualToString:NOTIFICATION_TYPE] && [message.is_read intValue] == 0) {
                self.redDotForNotifications.hidden = false;
                
            } else if ([message.type isEqualToString:MESSAGE_TYPE] && [message.is_read intValue] == 0) {
                self.redDotForMessages.hidden = false;
            }
        }
        [self loadData];
        [self.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [self.refreshControl endRefreshing];
    }];
}

- (void)loadData
{
    NSError *error = nil;
    BOOL fetchSuccessful = [[self getNSFetchedResultsController] performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch Error: %@",error);
    }
    if ([self isRetrievingConversations]) {
        [self.conversations removeAllObjects];
        NSMutableArray * latestMessages = [[NSMutableArray alloc] init];
        for (int i = 0; i < [[self.messageFetchedResultsController sections] count]; i++) {
            [latestMessages addObject:[self.messageFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]]];
        };
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        [self.conversations addObjectsFromArray:[latestMessages sortedArrayUsingDescriptors:@[sd]]];
    }
    [self.tableView reloadData];
}

- (BOOL) isRetrievingConversations
{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    switch (index) {
        case 1:return true;
        default:return false;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeedBasicTableViewCell *cell = (WeedBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    Message *message;
    if ([self isRetrievingConversations]) {
        message = [self.conversations objectAtIndex:indexPath.section];
        [cell setBackgroundColor:[UIColor clearColor]];
        NSIndexPath *originalIndexPathForMessage = [[self getNSFetchedResultsController] indexPathForObject:message];
        for(Message * message_in_section in [[[[self getNSFetchedResultsController] sections] objectAtIndex:originalIndexPathForMessage.section] objects]) {
            if ([message_in_section.is_read intValue] == 0) {
                [cell setBackgroundColor:[ColorDefinition lightGreenColor]];
            }
        }
    } else {
        message = [[self getNSFetchedResultsController] objectAtIndexPath:indexPath];
        if ([message.is_read intValue] == 0) {
            [cell setBackgroundColor:[ColorDefinition lightGreenColor]];
        } else {
            [cell setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    [cell decorateCellWithWeed:message.message username:message.participant_username time:message.time user_id:message.participant_id];
    cell.delegate = self;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isRetrievingConversations]) {
        return 1;
    }
    id sectionInfo = [[[self getNSFetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // only conversation needs to have multiple sections, section per conversation
    if ([self isRetrievingConversations]) {
        return [self.conversations count];
    } else {
        return 1;
    }
}

- (void) showUser:(id) sender
{
    [self performSegueWithIdentifier:@"showUser" sender:sender];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [[self getNSFetchedResultsController] objectAtIndexPath:indexPath];
    if (([message.type isEqualToString:NOTIFICATION_TYPE]) && message.related_weed_id) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/queryById/%@", message.related_weed_id]  parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if ([mappingResult.array count]) {
                self.relatedWeedToShow = mappingResult.array[0];
                //now mark this notification as read on server side
                [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"message/read/%@", message.id]  parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    message.is_read = [NSNumber numberWithInt:1];
                    [[[RKObjectManager sharedManager] managedObjectStore].mainQueueManagedObjectContext refreshObject:message mergeChanges:YES];
                    NSError *error = nil;
                    BOOL successful = [message.managedObjectContext save:&error];
                    if (! successful) {
                        NSLog(@"Save Error: %@",error);
                    }
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
                    [self performSegueWithIdentifier:@"showWeed" sender:self];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    RKLogError(@"Failed to call message/read due to error: %@", error);
                }];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Failed to query weed by id due to error: %@", error);
        }];
    } else if ([message.type isEqualToString:MESSAGE_TYPE]) {
        [self performSegueWithIdentifier:@"showMessage" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showWeed"]) {
        [[segue destinationViewController] setCurrentWeed:self.relatedWeedToShow];
    } else if ([[segue identifier] isEqualToString:@"showMessage"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Message * message = [self.conversations objectAtIndex:selectedIndexPath.section];
        [[segue destinationViewController] setParticipant_username:message.participant_username];
        [[segue destinationViewController] setParticipant_id:message.participant_id];
    } else if ([[segue identifier] isEqualToString:@"showUser"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Message *message;
        if ([self isRetrievingConversations])
            message = [self.conversations objectAtIndex:indexPath.section];
        else
            message = [[self getNSFetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setUser_id:message.participant_id];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
