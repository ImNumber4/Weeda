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
#import "WLCoreDataHelper.h"

@interface BongsViewController () <WeedDetailTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) NSMutableArray *weeds;
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSMutableDictionary *heights;
@property (nonatomic) CGFloat detailWeedCellHeight;
@property (nonatomic, retain) UITableView * tableView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation BongsViewController

static NSString * WEED_DETAIL_TABLE_CELL_REUSE_ID_PREFIX = @"WeedDetailCell";
static NSString * USER_CELL_ID = @"UserCell";
static NSString * FIND_MORE_CELL_ID = @"FindMoreCell";

static int USERS_SECTION = 0;
static int WEEDS_SECTION = 1;

static double MORE_CELL_HEIGHT = 35;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bongs";
    
    self.weeds = [[NSMutableArray alloc] init];
    self.users = [[NSMutableArray alloc] init];
    self.heights = [[NSMutableDictionary alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_CELL_ID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:FIND_MORE_CELL_ID];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    [WLCoreDataHelper addCoreDataChangedNotificationTo:self selecter:@selector(objectChangedNotificationReceived:)];
    
    [self fetachData];
}

- (void)selectWeedContent:(UIGestureRecognizer *)recognizer
{
    UITableView *target = self.tableView;

    CGPoint selectPoint = [recognizer locationInView:target];
    NSIndexPath *indexPath = [target indexPathForRowAtPoint:selectPoint];
    [target selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:target didSelectRowAtIndexPath:indexPath];
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
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WEEDS_SECTION) {
        Weed * weed = [self.weeds objectAtIndex:indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        [controller setCurrentWeed:weed];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == USERS_SECTION) {
        if (indexPath.row < [self.users count]) {
            User *user = [self.users objectAtIndex:indexPath.row];
            UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
            [controller setUser_id:user.id];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            UserListViewController* viewController = [[UserListViewController alloc] initWithNibName:nil bundle:nil];
            [viewController setUrlPathToPullUsers:[NSString stringWithFormat:@"user/getRecommendedUsers/%d", 20]];
            viewController.title = @"Recommended Users";
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
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
    UITableView *target = self.tableView;

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:target];
    NSIndexPath *indexPath = [target indexPathForRowAtPoint:buttonPosition];
    Weed *weed = [self.weeds objectAtIndex:indexPath.row];
    UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
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

- (void)objectChangedNotificationReceived:(NSNotification *)notification
{
    NSArray *deleteWeeds = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (Weed *weed in deleteWeeds) {
        if ([self.weeds containsObject:weed]) {
            NSUInteger row = [self.weeds indexOfObject:weed];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:WEEDS_SECTION];
            [self.weeds removeObject:weed];
            if ([self.tableView cellForRowAtIndexPath:indexPath]) {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
            }
        }
    }
}

@end
