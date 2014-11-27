//
//  SearchViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "SearchViewController.h"
#import "UserViewController.h"
#import "UserTableViewCell.h"
#import "DetailViewController.h"
#import "ImageUtil.h"
#import "WeedTableViewCell.h"
#import "WLCoreDataHelper.h"
#import "WLWebViewController.h"

@interface SearchViewController() <UITableViewDataSource, UITableViewDelegate, WeedTableViewCellDelegate, UISearchBarDelegate>
@property (nonatomic, retain) NSMutableArray *matchedWeeds;
@property (nonatomic, retain) NSMutableArray *matchedUsers;
@property (nonatomic, retain) UISegmentedControl * segmentedControl;
@property (nonatomic, retain) UITableView *searchResultTableView;
@property (nonatomic, retain) UISearchBar *searchBar;
@end

@implementation SearchViewController

static NSString * USER_CELL_ID = @"UserCell";
static NSString * FIND_MORE_CELL_ID = @"FindMoreCell";
static NSString * WEED_TABLE_CELL_REUSE_ID = @"WeedCell";

static double PADDING = 5;

static const NSInteger SEGMENTED_CONTROL_ALL = 0;
static const NSInteger SEGMENTED_CONTROL_WEEDS_ONLY = 1;
static const NSInteger SEGMENTED_CONTROL_USERS_ONLY = 2;

static int USERS_SECTION = 0;
static int WEEDS_SECTION = 1;

static double MORE_CELL_HEIGHT = 35;

static NSInteger MAX_ROWS_TO_SHOW_IN_ALL_SEARCH = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.matchedUsers = [[NSMutableArray alloc] init];
    self.matchedWeeds = [[NSMutableArray alloc] init];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.hidden = true;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translucent = true;
    self.searchBar.delegate = self;
    [self.searchBar setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon.png"] color:[UIColor whiteColor]] atSize:CGSizeMake(10, 10)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self setSearchBarTextColorToBeWhite];
    
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.hidden = false;
    [self.searchBar setAlpha:0.0];
    
    [self.navigationItem setRightBarButtonItem:[self getCancelButton]];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    double segmentedControlY = statusBarSize.height + self.navigationController.navigationBar.frame.size.height + PADDING;
    double segmentedControlHeight = 25;
    
    double searchResultTableViewY = segmentedControlY + segmentedControlHeight + PADDING;
    self.searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, searchResultTableViewY, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - searchResultTableViewY)  style:UITableViewStyleGrouped];
    self.searchResultTableView.dataSource = self;
    self.searchResultTableView.delegate = self;
    [self.searchResultTableView setSeparatorInset:UIEdgeInsetsZero];
    self.searchResultTableView.tableFooterView = [[UIView alloc] init];
    [self.searchResultTableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_CELL_ID];
    [self.searchResultTableView registerClass:[WeedTableViewCell class] forCellReuseIdentifier:WEED_TABLE_CELL_REUSE_ID];
    [self.searchResultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:FIND_MORE_CELL_ID];
    
    [self.view addSubview:self.searchResultTableView];
    [self.view setBackgroundColor:self.searchResultTableView.backgroundColor];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Weeds", @"User"]];
    [self.segmentedControl setFrame:CGRectMake(PADDING, segmentedControlY, self.view.frame.size.width - PADDING * 2, segmentedControlHeight)];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl setTintColor:[UIColor grayColor]];
    [self.segmentedControl setBackgroundColor:[UIColor clearColor]];
    [self.segmentedControl addTarget:self action:@selector(segmentSwitched:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    [WLCoreDataHelper addCoreDataChangedNotificationTo:self selecter:@selector(objectChangedNotificationReceived:)];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.searchBar setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self.searchBar becomeFirstResponder];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar endEditing:TRUE];
}

- (void) setSearchBarTextColorToBeWhite
{
    for (UIView *subView in self.searchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = [UIColor whiteColor];
                
                break;
            }
        }
    }
}

-(void)segmentSwitched:(UISegmentedControl *)seg{
    [self.searchResultTableView reloadData];
}

- (UIBarButtonItem *) getCancelButton
{
    return [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed:)];
}

-(void)cancelPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 1.0f;
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case SEGMENTED_CONTROL_ALL:
            return 2;
        default:
            return 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case SEGMENTED_CONTROL_ALL:
            if (indexPath.section == USERS_SECTION) {
                if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedUsers count])) {
                    [self.segmentedControl setSelectedSegmentIndex:SEGMENTED_CONTROL_USERS_ONLY];
                    [self.searchResultTableView reloadData];
                } else {
                    User * user = [self.matchedUsers objectAtIndex:indexPath.row];
                    UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
                    [controller setUser_id:user.id];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            } else if (indexPath.section == WEEDS_SECTION) {
                if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedWeeds count])) {
                    [self.segmentedControl setSelectedSegmentIndex:SEGMENTED_CONTROL_WEEDS_ONLY];
                    [self.searchResultTableView reloadData];
                } else {
                    Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];
                    DetailViewController *controller = (DetailViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
                    [controller setCurrentWeed:weed];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            break;
        case SEGMENTED_CONTROL_USERS_ONLY:
        {
            User * user = [self.matchedUsers objectAtIndex:indexPath.row];
            UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
            [controller setUser_id:user.id];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case SEGMENTED_CONTROL_WEEDS_ONLY:
        {
            Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];
            DetailViewController *controller = (DetailViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
            [controller setCurrentWeed:weed];
            [self.navigationController pushViewController:controller animated:YES];
        }
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case SEGMENTED_CONTROL_ALL:
            if (section == USERS_SECTION) {
                if ([self.matchedUsers count] == 0) {
                    return 0;
                }
                return MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedUsers count]) + 1;
            } else if (section == WEEDS_SECTION) {
                if ([self.matchedWeeds count] == 0) {
                    return 0;
                }
                return MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedWeeds count]) + 1;
            } else {
                return 0;
            }
        case SEGMENTED_CONTROL_USERS_ONLY:
            return [self.matchedUsers count];
        case SEGMENTED_CONTROL_WEEDS_ONLY:
            return [self.matchedWeeds count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case SEGMENTED_CONTROL_ALL:
            if (indexPath.section == USERS_SECTION) {
                if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedUsers count])) {
                    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:FIND_MORE_CELL_ID forIndexPath:indexPath];
                    cell.textLabel.text = @"More";
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                } else {
                    UserTableViewCell *cell = (UserTableViewCell *) [tableView dequeueReusableCellWithIdentifier:USER_CELL_ID forIndexPath:indexPath];
                    User * user = [self.matchedUsers objectAtIndex:indexPath.row];
                    [cell decorateCellWithUser:user];
                    return cell;
                }
            } else if (indexPath.section == WEEDS_SECTION) {
                if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedWeeds count])) {
                    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:FIND_MORE_CELL_ID forIndexPath:indexPath];
                    cell.textLabel.text = @"More";
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                } else {
                    WeedTableViewCell *cell = (WeedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:WEED_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
                    Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];
                    [cell decorateCellWithWeed:weed parentViewController:self];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            } else {
                return nil;
            }
        case SEGMENTED_CONTROL_USERS_ONLY:
        {
            UserTableViewCell *cell = (UserTableViewCell *) [tableView dequeueReusableCellWithIdentifier:USER_CELL_ID forIndexPath:indexPath];
            User * user = [self.matchedUsers objectAtIndex:indexPath.row];
            [cell decorateCellWithUser:user];
            return cell;
        }
        case SEGMENTED_CONTROL_WEEDS_ONLY:
        {
            WeedTableViewCell *cell = (WeedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:WEED_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
            Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];
            [cell decorateCellWithWeed:weed parentViewController:self];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case SEGMENTED_CONTROL_ALL:
            if (indexPath.section == USERS_SECTION) {
                if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedUsers count])) {
                    return MORE_CELL_HEIGHT;
                } else {
                    return USER_TABLE_VIEW_CELL_HEIGHT;
                }
            } else if (indexPath.section == WEEDS_SECTION) {
                
                if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedWeeds count])) {
                    return MORE_CELL_HEIGHT;
                } else {
                    Weed * weed = [self.matchedWeeds objectAtIndex:indexPath.row];
                    return [WeedTableViewCell heightOfWeedTableViewCell:weed width:tableView.frame.size.width];
                }
            } else {
                return 0.0;
            }
        case SEGMENTED_CONTROL_USERS_ONLY:
            return USER_TABLE_VIEW_CELL_HEIGHT;
        case SEGMENTED_CONTROL_WEEDS_ONLY:
        {
            Weed * weed = [self.matchedWeeds objectAtIndex:indexPath.row];
            return [WeedTableViewCell heightOfWeedTableViewCell:weed width:tableView.frame.size.width];
        }
        default:
            return 0;
    }
}

#pragma searchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:TRUE];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getUsernamesByPrefix/%@", searchBar.text] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.matchedUsers removeAllObjects];
        [self.matchedUsers addObjectsFromArray:mappingResult.array];
        switch (self.segmentedControl.selectedSegmentIndex) {
            case SEGMENTED_CONTROL_ALL:
                [self.searchResultTableView reloadSections:[NSIndexSet indexSetWithIndex:USERS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            default:
                [self.searchResultTableView reloadData];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load getUsernamesByPrefix failed with error: %@", error);
    }];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/queryByContent/%@", searchBar.text] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.matchedWeeds removeAllObjects];
        for (Weed * weed in mappingResult.array) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.matchedWeeds addObject:weed];
            }
        }
        [self.matchedWeeds sortUsingComparator:^NSComparisonResult(Weed *obj1, Weed *obj2) {
            return [obj1.time compare: obj2.time] == NSOrderedAscending;
        }];
        switch (self.segmentedControl.selectedSegmentIndex) {
            case SEGMENTED_CONTROL_ALL:
                [self.searchResultTableView reloadSections:[NSIndexSet indexSetWithIndex:WEEDS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            default:
                [self.searchResultTableView reloadData];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load queryByContent failed with error: %@", error);
    }];
}

#pragma tablecell Delegate
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

- (void)showUserViewController:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.searchResultTableView];
    NSIndexPath *indexPath = [self.searchResultTableView indexPathForRowAtPoint:buttonPosition];
    Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];

    UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
    [controller setUser_id:weed.user_id];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)objectChangedNotificationReceived:(NSNotification *)notification
{
    NSArray *deleteWeeds = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (Weed *weed in deleteWeeds) {
        if ([self.matchedWeeds containsObject:weed]) {
            NSUInteger row = [self.matchedWeeds indexOfObject:weed];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:WEEDS_SECTION];
            [self.matchedWeeds removeObject:weed];
            if ([self.searchResultTableView cellForRowAtIndexPath:indexPath]) {
                [self.searchResultTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
            }
        }
    }
}

- (void)selectWeedContent:(UIGestureRecognizer *)recognizer
{
    UITableView *target = self.searchResultTableView;

    CGPoint selectPoint = [recognizer locationInView:target];
    NSIndexPath *indexPath = [target indexPathForRowAtPoint:selectPoint];
    [target selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:target didSelectRowAtIndexPath:indexPath];
}

@end
