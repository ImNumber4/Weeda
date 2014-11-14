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
#import "WeedBasicTableViewCell.h"
#import "Weed.h"
#import "User.h"
#import "WeedImage.h"
#import "WLWebViewController.h"

#import <RestKit/RestKit.h>

@interface MasterViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NSFetchedResultsControllerDelegate, WeedTableViewCellDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property double previousScrollViewYOffset;
@property BOOL scrollingNavBarEnabled;

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
    
    self.previousScrollViewYOffset = 0.0;
    
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

- (void) viewDidAppear:(BOOL)animated
{
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:1];
    self.scrollingNavBarEnabled = true;
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.scrollingNavBarEnabled = false;
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:1];
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
    if ([sender tag] != GLOBAL_COMPOSE_TAG) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Weed *weed = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [AddWeedViewController presentControllerFrom:self withWeed:weed];
    } else {
        [AddWeedViewController presentControllerFrom:self withWeed:nil];
    }
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
    
    return [WeedTableViewCell heightOfWeedTableViewCell:weed];
}

- (void)decorateCellWithWeed:(Weed *)weed cell:(WeedTableViewCell *)cell
{
    [cell decorateCellWithWeed:weed];
    
    cell.delegate = self;
    
    [cell.waterDrop removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.waterDrop addTarget:self action:@selector(waterIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.seed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.seed addTarget:self action:@selector(seedIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.light removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.light addTarget:self action:@selector(lightIt:)forControlEvents:UIControlEventTouchDown];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showWeed" sender:self];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}

#pragma WeedTableViewCell Delegate
- (void)showUserViewController:(id)sender
{
    [self performSegueWithIdentifier:@"showUser" sender:sender];
}

- (void)selectWeedContent:(UIGestureRecognizer *)recognizer
{
    CGPoint selectPoint = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:selectPoint];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.scrollingNavBarEnabled) return;
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.scrollingNavBarEnabled) return;
    [self stoppedScrolling];
}

- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha]}];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}

#pragma WeedTableViewCell Delegate
- (BOOL)pressURL:(NSURL *)url
{
    WLWebViewController *webViewController = [[WLWebViewController alloc]init];
    webViewController.url = url;

    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:webViewController animated:NO];

    [UIView animateWithDuration:0.5 animations:^{
        self.tabBarController.tabBar.alpha = 0.0;
    }];
    
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
