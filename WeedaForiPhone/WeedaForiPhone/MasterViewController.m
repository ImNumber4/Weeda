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
#import "Weed.h"
#import "User.h"
#import "WeedImage.h"
#import "WLWebViewController.h"
#import "WLCoreDataHelper.h"
#import "ImageUtil.h"
#import <RestKit/RestKit.h>
#import "SearchViewController.h"

@interface MasterViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, WeedTableViewCellDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property double previousScrollViewYOffset;
@property BOOL scrollingNavBarEnabled;

@end

@implementation MasterViewController

static NSString *TABLE_CELL_REUSE_ID = @"WeedTableCell";

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previousScrollViewYOffset = 0.0;
    
    [self.tableView registerClass:[WeedTableViewCell class] forCellReuseIdentifier:TABLE_CELL_REUSE_ID];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self.navigationItem setRightBarButtonItem:[self getSearchButton]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Weed"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    
    //Add weed core data notification for change moniter
    [WLCoreDataHelper addCoreDataChangedNotificationTo:self selecter:@selector(objectChangedNotificationReceived:)];
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[self getImage:@"compose.png" width:30 height:30] style:UIBarButtonItemStylePlain target:self action:@selector(lightIt:)];
    [self.navigationItem setLeftBarButtonItem:composeButton];
    
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Error: %@",error);
    }
    [self.tableView reloadData];
    [self loadData];
}

- (UIBarButtonItem *) getSearchButton
{
    return [[UIBarButtonItem alloc] initWithImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon.png"] color:[UIColor whiteColor]] atSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchBar:)];
}

-(void)displaySearchBar:(id)sender {
    SearchViewController *controller = [[SearchViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
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
        NSError *error = nil;
        BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
        if (! fetchSuccessful) {
            NSLog(@"Error: %@",error);
        } else {
            [self.tableView reloadData];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
}

-(void)lightIt:(id)sender {
    [AddWeedViewController presentControllerFrom:self withWeed:nil];
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
    return NO;
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
    WeedTableViewCell *cell = (WeedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:TABLE_CELL_REUSE_ID forIndexPath:indexPath];
    Weed *weed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self decorateCellWithWeed:weed cell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    Weed *weed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return [WeedTableViewCell heightOfWeedTableViewCell:weed width:tableView.frame.size.width];
}

- (void)decorateCellWithWeed:(Weed *)weed cell:(WeedTableViewCell *)cell
{
    [cell decorateCellWithWeed:weed parentViewController:self];
    
    cell.delegate = self;
}

- (UIImage *)getImage:(NSString *)imageName width:(int)width height:(int) height
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
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

- (void)objectChangedNotificationReceived:(NSNotification *)notification
{
    NSArray *deleteObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (Weed *weed in deleteObjects) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:weed];
        if (indexPath) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            if ([self.tableView cellForRowAtIndexPath:indexPath]) {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
            }
        }
    }
}

@end
