//
//  TrendTableViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/15/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "BongsViewController.h"
#import "WeedDetailTableViewCell.h"
#import "WLWebViewController.h"
#import "UserTableViewCell.h"
#import "DetailViewController.h"
#import "UserViewController.h"
#import "UserTableViewCell.h"
#import "UserListViewController.h"
#import "ImageUtil.h"
#import "BlurView.h"
#import "WeedTableViewCell.h"

@interface BongsViewController () <WeedDetailTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate, WeedTableViewCellDelegate, UISearchBarDelegate>
@property (nonatomic, retain) NSMutableArray *weeds;
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSMutableArray *matchedWeeds;
@property (nonatomic, retain) NSMutableArray *matchedUsers;
@property (nonatomic, retain) NSMutableDictionary *heights;
@property (nonatomic) CGFloat detailWeedCellHeight;
@property (nonatomic, retain) UITableView * tableView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UIView * blurView;
@property (nonatomic, retain) UISegmentedControl * segmentedControl;
@property (nonatomic, retain) UITableView *searchResultTableView;

@end

@implementation BongsViewController

static NSString * WEED_DETAIL_TABLE_CELL_REUSE_ID_PREFIX = @"WeedDetailCell";
static NSString * USER_CELL_ID = @"UserCell";
static NSString * FIND_MORE_CELL_ID = @"FindMoreCell";
static NSString * WEED_TABLE_CELL_REUSE_ID = @"WeedCell";

static int USERS_SECTION = 0;
static int WEEDS_SECTION = 1;

static double PADDING = 5;

static double MORE_CELL_HEIGHT = 35;

static NSInteger BONGS_TABLE_VIEW = 0;
static NSInteger SEARCH_RESULT_TABLE_VIEW = 1;

static const NSInteger SEGMENTED_CONTROL_ALL = 0;
static const NSInteger SEGMENTED_CONTROL_WEEDS_ONLY = 1;
static const NSInteger SEGMENTED_CONTROL_USERS_ONLY = 2;

static NSInteger MAX_ROWS_TO_SHOW_IN_ALL_SEARCH = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bongs";
    
    self.weeds = [[NSMutableArray alloc] init];
    self.users = [[NSMutableArray alloc] init];
    self.matchedUsers = [[NSMutableArray alloc] init];
    self.matchedWeeds = [[NSMutableArray alloc] init];
    self.heights = [[NSMutableDictionary alloc] init];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.hidden = true;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translucent = true;
    self.searchBar.delegate = self;
    [self.searchBar setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon.png"] color:[UIColor whiteColor]] atSize:CGSizeMake(10, 10)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self setSearchBarTextColorToBeWhite];
    
    [self.navigationItem setRightBarButtonItem:[self getSearchButton]];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_CELL_ID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:FIND_MORE_CELL_ID];
    self.tableView.tag = BONGS_TABLE_VIEW;
    
    self.blurView = [[UIView alloc] initWithFrame:self.tableView.frame];
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    double segmentedControlY = statusBarSize.height + self.navigationController.navigationBar.frame.size.height + PADDING;
    double segmentedControlHeight = 25;
    
    double searchResultTableViewY = segmentedControlY + segmentedControlHeight + PADDING;
    self.searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, searchResultTableViewY, self.blurView.frame.size.width, self.blurView.frame.size.height - self.tabBarController.tabBar.frame.size.height - searchResultTableViewY)  style:UITableViewStyleGrouped];
    self.searchResultTableView.dataSource = self;
    self.searchResultTableView.delegate = self;
    self.searchResultTableView.tag = SEARCH_RESULT_TABLE_VIEW;
    [self.searchResultTableView setSeparatorInset:UIEdgeInsetsZero];
    self.searchResultTableView.tableFooterView = [[UIView alloc] init];
    [self.searchResultTableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_CELL_ID];
    [self.searchResultTableView registerClass:[WeedTableViewCell class] forCellReuseIdentifier:WEED_TABLE_CELL_REUSE_ID];
    [self.searchResultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:FIND_MORE_CELL_ID];
    [self.blurView addSubview:self.searchResultTableView];
    [self.blurView setBackgroundColor:self.searchResultTableView.backgroundColor];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Weeds", @"User"]];
    [self.segmentedControl setFrame:CGRectMake(PADDING, segmentedControlY, self.blurView.frame.size.width - PADDING * 2, segmentedControlHeight)];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl setTintColor:[UIColor grayColor]];
    [self.segmentedControl setBackgroundColor:[UIColor clearColor]];
    [self.segmentedControl addTarget:self action:@selector(segmentSwitched:) forControlEvents:UIControlEventValueChanged];
    [self.blurView addSubview:self.segmentedControl];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    [self fetachData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.searchBar.hidden) {
        [self.searchBar endEditing:TRUE];
    }
}

-(void)segmentSwitched:(UISegmentedControl *)seg{
    [self.searchResultTableView reloadData];
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

- (UIBarButtonItem *) getSearchButton
{
    return [[UIBarButtonItem alloc] initWithImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon.png"] color:[UIColor whiteColor]] atSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchBar:)];
}

- (UIBarButtonItem *) getCancelButton
{
    return [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchBar:)];
}

- (void)selectWeedContent:(UIGestureRecognizer *)recognizer
{
    UITableView *target;
    if (self.searchBar.hidden) {
        target = self.tableView;
    } else {
        target = self.searchResultTableView;
    }
    CGPoint selectPoint = [recognizer locationInView:target];
    NSIndexPath *indexPath = [target indexPathForRowAtPoint:selectPoint];
    [target selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:target didSelectRowAtIndexPath:indexPath];
}

-(void)displaySearchBar:(id)sender {
    if (self.searchBar.hidden) {
        self.navigationItem.titleView = self.searchBar;
        self.searchBar.hidden = false;
        [self.searchBar setAlpha:0.0];
        [self.view insertSubview:self.blurView aboveSubview:self.tableView];
        [self.navigationItem setRightBarButtonItem:[self getCancelButton]];
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self.searchBar becomeFirstResponder];
        }];
    } else {
        [self.navigationItem setRightBarButtonItem:[self getCancelButton]];
        [self.searchBar resignFirstResponder];
        [self.blurView removeFromSuperview];
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.navigationItem.titleView = nil;
            self.searchBar.hidden = true;
            [self.navigationItem setRightBarButtonItem:[self getSearchButton]];
        }];
    }
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self fetachData];
}

- (void)fetachData
{
    // Load the object model via RestKit
    [[RKObjectManager sharedManager] getObjectsAtPath:@"weed/trends" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.weeds removeAllObjects];
        for (Weed * weed in mappingResult.array) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.weeds addObject:weed];
            }
        }
        [self.weeds sortUsingComparator:^NSComparisonResult(Weed *obj1, Weed *obj2) {
            return [obj1.score intValue] < [obj2.score intValue];
        }];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:WEEDS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [self.refreshControl endRefreshing];
    }];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getRecommendedUsers/%d", 3] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.users removeAllObjects];
        for (User * user in mappingResult.array) {
            [self.users addObject:user];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:USERS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == SEARCH_RESULT_TABLE_VIEW) {
        if (section == 0)
            return 1.0f;
        return 20;
    } else {
        return 20;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == BONGS_TABLE_VIEW) {
        return 2;
    } else if (tableView.tag == SEARCH_RESULT_TABLE_VIEW) {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case SEGMENTED_CONTROL_ALL:
                return 2;
            default:
                return 1;
        }
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == BONGS_TABLE_VIEW) {
        if (indexPath.section == WEEDS_SECTION) {
            Weed * weed = [self.weeds objectAtIndex:indexPath.row];
            DetailViewController *controller = (DetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
            [controller setCurrentWeed:weed];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.section == USERS_SECTION) {
            if (indexPath.row < [self.users count]) {
                User *user = [self.users objectAtIndex:indexPath.row];
                UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
                [controller setUser_id:user.id];
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                self.tableView.userInteractionEnabled = false;
                [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getRecommendedUsers/%d", 20] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    UserListViewController* viewController = [[UserListViewController alloc] initWithNibName:nil bundle:nil];
                    [viewController setUsers:mappingResult.array];
                    viewController.title = @"Recommended Users";
                    [self.navigationController pushViewController:viewController animated:YES];
                    self.tableView.userInteractionEnabled = true;
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    RKLogError(@"Load failed with error: %@", error);
                    self.tableView.userInteractionEnabled = true;
                }];
            }
        }
    } else if (tableView.tag == SEARCH_RESULT_TABLE_VIEW) {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case SEGMENTED_CONTROL_ALL:
                if (indexPath.section == USERS_SECTION) {
                    if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedUsers count])) {
                        [self.segmentedControl setSelectedSegmentIndex:SEGMENTED_CONTROL_USERS_ONLY];
                        [self.searchResultTableView reloadData];
                    } else {
                        User * user = [self.matchedUsers objectAtIndex:indexPath.row];
                        UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
                        [controller setUser_id:user.id];
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                } else if (indexPath.section == WEEDS_SECTION) {
                    if (indexPath.row == MIN(MAX_ROWS_TO_SHOW_IN_ALL_SEARCH, [self.matchedWeeds count])) {
                        [self.segmentedControl setSelectedSegmentIndex:SEGMENTED_CONTROL_WEEDS_ONLY];
                        [self.searchResultTableView reloadData];
                    } else {
                        Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];
                        DetailViewController *controller = (DetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
                        [controller setCurrentWeed:weed];
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                }
                break;
            case SEGMENTED_CONTROL_USERS_ONLY:
            {
                User * user = [self.matchedUsers objectAtIndex:indexPath.row];
                UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
                [controller setUser_id:user.id];
                [self.navigationController pushViewController:controller animated:YES];
                break;
            }
            case SEGMENTED_CONTROL_WEEDS_ONLY:
            {
                Weed *weed = [self.matchedWeeds objectAtIndex:indexPath.row];
                DetailViewController *controller = (DetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
                [controller setCurrentWeed:weed];
                [self.navigationController pushViewController:controller animated:YES];
            }
            default:
                break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == BONGS_TABLE_VIEW) {
        if (section == USERS_SECTION) {
            if ([self.users count] == 0) {
                return 0;
            }
            return [self.users count] + 1;
        } else if (section == WEEDS_SECTION) {
            return [self.weeds count];
        } else {
            return 0;
        }
    } else if (tableView.tag == SEARCH_RESULT_TABLE_VIEW) {
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
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == BONGS_TABLE_VIEW) {
        if (indexPath.section == WEEDS_SECTION) {
            Weed * weed = [self.weeds objectAtIndex:indexPath.row];
            NSString *reuseId = [NSString stringWithFormat:@"%@%@", WEED_DETAIL_TABLE_CELL_REUSE_ID_PREFIX, weed.id];
            [self.tableView registerClass:[WeedDetailTableViewCell class] forCellReuseIdentifier:reuseId];
            
            WeedDetailTableViewCell *weedDetailTableViewCell = (WeedDetailTableViewCell *) [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
            
            if (!weedDetailTableViewCell.weed) {
                weedDetailTableViewCell.delegate = self;
                [weedDetailTableViewCell decorateCellWithWeed:weed parentViewController:self showHeader:true];
                weedDetailTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return weedDetailTableViewCell;
        } else if (indexPath.section == USERS_SECTION) {
            if (indexPath.row == [self.users count]) {
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:FIND_MORE_CELL_ID forIndexPath:indexPath];
                cell.textLabel.text = @"Find More People";
                [cell.textLabel setTextColor:[UIColor grayColor]];
                [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else {
                UserTableViewCell *cell = (UserTableViewCell *) [tableView dequeueReusableCellWithIdentifier:USER_CELL_ID forIndexPath:indexPath];
                User * user = [self.users objectAtIndex:indexPath.row];
                [cell decorateCellWithUser:user];
                return cell;
            }
        } else {
            return nil;
        }
    } else if (tableView.tag == SEARCH_RESULT_TABLE_VIEW) {
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
    } else {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView.tag == BONGS_TABLE_VIEW) {
        if (indexPath.section == USERS_SECTION) {
            if (indexPath.row == [self.users count]) {
                return MORE_CELL_HEIGHT;
            } else {
                return USER_TABLE_VIEW_CELL_HEIGHT;
            }
        } else if (indexPath.section == WEEDS_SECTION) {
            Weed * weed = [self.weeds objectAtIndex:indexPath.row];
            NSNumber *height = [self.heights objectForKey:weed.id];
            return height? [height floatValue] : [WeedDetailTableViewCell heightForCell:weed showHeader:true];
        } else {
            return 0.0;
        }
    } else if (tableView.tag == SEARCH_RESULT_TABLE_VIEW) {
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
                        return [WeedTableViewCell heightOfWeedTableViewCell:weed];
                    }
                } else {
                    return 0.0;
                }
            case SEGMENTED_CONTROL_USERS_ONLY:
                return USER_TABLE_VIEW_CELL_HEIGHT;
            case SEGMENTED_CONTROL_WEEDS_ONLY:
            {
                Weed * weed = [self.matchedWeeds objectAtIndex:indexPath.row];
                return [WeedTableViewCell heightOfWeedTableViewCell:weed];
            }
            default:
                return 0;
        }
    } else {
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

- (void)tableViewCell:(WeedDetailTableViewCell *)cell height:(CGFloat)height needReload:(BOOL)needReload
{
    [self.heights setObject:[NSNumber numberWithFloat:height] forKey:cell.weed.id];
    
    if (needReload) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (void)showUserViewController:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Weed *weed = [self.weeds objectAtIndex:indexPath.row];
    UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    [controller setUser_id:weed.user_id];
    [self.navigationController pushViewController:controller animated:YES];
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
