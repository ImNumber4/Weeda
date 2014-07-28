//
//  MasterViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//
#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AddWeedViewController.h"
#import "UserViewController.h"
#import "WeedTableViewCell.h"
#import <RestKit/RestKit.h>
#import "Weed.h"
#import "User.h"
#import "WeedImage.h"


@interface MasterViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSFetchedResultsController *imageFetchedController;

@end

@implementation MasterViewController

const NSInteger GLOBAL_COMPOSE_TAG = 0;
const NSInteger NON_GLOBAL_COMPOSE_TAG = 1;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Weed"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[self getImage:@"compose.png" width:30 height:30] style:UIBarButtonItemStylePlain target:self action:@selector(lightIt:)];
    composeButton.tag = GLOBAL_COMPOSE_TAG;
    [self.navigationItem setRightBarButtonItem:composeButton];
    
    [self.fetchedResultsController setDelegate:self];
    
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Error: %@",error);
    }
    
    [self loadData];
}

- (void)loadData
{
    
    // Load the object model via RestKit
    [[RKObjectManager sharedManager] getObjectsAtPath:@"weed/query" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
}

-(void)lightIt:(id)sender {
    [self performSegueWithIdentifier:@"addWeed" sender:sender];
}

-(void)showUser:(id)sender {
    [self performSegueWithIdentifier:@"showUser" sender:sender];
}


-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];

    [self loadData];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    Weed * weed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [weed.user_id intValue] == [appDelegate.currentUser.id integerValue]?YES:NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Weed * weed = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[RKObjectManager sharedManager] deleteObject:weed path:[NSString stringWithFormat:@"weed/delete/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"Response: %@", mappingResult);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Failure saving post: %@", error.localizedDescription);
        }];
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeedTableCell";
    WeedTableViewCell *cell = (WeedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Weed *weed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self decorateCellWithWeed:weed cell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    Weed *weed = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:12.0];
    temp.text = weed.content;
    
    CGFloat textViewWidth = 200.0;
    CGRect tempFrame = CGRectMake(0, 0, textViewWidth, 50); //The height of this frame doesn't matter.
    CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.
    
    //Add the height of the other UI elements inside your cell
    if ([weed.image_count intValue] > 0) {
        return MAX(tvsize.height, 50.0) + 20.0 + 260.0; //For Image View
    } else {
        return MAX(tvsize.height, 50.0) + 20.0;
    }
}

- (void)decorateCellWithWeed:(Weed *)weed cell:(WeedTableViewCell *)cell
{
    [cell decorateCellWithWeed:weed];
    [cell.waterDrop removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.waterDrop addTarget:self action:@selector(waterIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.seed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.seed addTarget:self action:@selector(seedIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.light removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.light addTarget:self action:@selector(lightIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.usernameLabel removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.usernameLabel addTarget:self action:@selector(showUser:)forControlEvents:UIControlEventTouchDown];
    
    cell.light.tag = NON_GLOBAL_COMPOSE_TAG;
}

- (void)getImageFromServer:(UIImage *)image cell:(WeedTableViewCell *)cell
{
    cell.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    cell.userAvatar.clipsToBounds = YES;
    if (!image) {
        cell.userAvatar.image = [self getImage:@"avatar.jpg" width:40 height:40];
    } else {
        cell.userAvatar.image = [self decorateImage:image width:40 height:40];
    }
    
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

- (UIImage *)getImage:(NSString *)imageName width:(int)width height:(int) height
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (UIImage *)decorateImage:(UIImage *)image width:(int)width height:(int) height
{
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)waterIt:(id) sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Weed *weed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([weed.if_cur_user_water_it intValue] == 1) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unwater/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] - 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:0];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/water/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] + 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:1];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    }
    WeedTableViewCell *cell = (WeedTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self decorateCellWithWeed:weed cell:cell];
}

- (void)seedIt:(id) sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Weed *weed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([weed.if_cur_user_seed_it intValue] == 1) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unseed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] - 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:0];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/seed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] + 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:1];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    }
    WeedTableViewCell *cell = (WeedTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self decorateCellWithWeed:weed cell:cell];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showWeed"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Weed *weed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setCurrentWeed:weed];
    } else if ([[segue identifier] isEqualToString:@"addWeed"]) {
        if ([sender tag] != GLOBAL_COMPOSE_TAG) {
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
            Weed *weed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            UINavigationController* nav = [segue destinationViewController];
            AddWeedViewController* addWeedController = (AddWeedViewController *) nav.topViewController;
            [addWeedController setLightWeed:weed];
        }
    } else if ([[segue identifier] isEqualToString:@"showUser"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Weed *weed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setUser_id:weed.user_id];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return [self.fetchedResultsController sectionIndexTitles];
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo name];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}



@end
