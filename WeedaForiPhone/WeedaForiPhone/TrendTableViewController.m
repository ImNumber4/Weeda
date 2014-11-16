//
//  TrendTableViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/15/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "TrendTableViewController.h"
#import "WeedDetailTableViewCell.h"
#import "WLWebViewController.h"
#import "UserTableViewCell.h"

@interface TrendTableViewController () <WeedDetailTableViewCellDelegate>
@property (nonatomic, retain) NSMutableArray *weeds;
@property (nonatomic, retain) NSMutableDictionary *heights;
@property (nonatomic) CGFloat detailWeedCellHeight;
@property (nonatomic) NSArray *sortDescriptors;

@end

@implementation TrendTableViewController

static NSString * WEED_DETAIL_TABLE_CELL_REUSE_ID_PREFIX = @"WeedDetailCell";
static NSString * HEADER_CELL_REUSE_ID = @"HeaderCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bongs";
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:HEADER_CELL_REUSE_ID];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score"
                                                 ascending:NO];
    self.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.weeds = [[NSMutableArray alloc] init];
    self.heights = [[NSMutableDictionary alloc] init];
    [self fetachData];
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
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [self.refreshControl endRefreshing];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.weeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Weed * weed = [self.weeds objectAtIndex:indexPath.section];
    NSString *reuseId = [NSString stringWithFormat:@"%@%@", WEED_DETAIL_TABLE_CELL_REUSE_ID_PREFIX, weed.id];
    [self.tableView registerClass:[WeedDetailTableViewCell class] forCellReuseIdentifier:reuseId];
    
    WeedDetailTableViewCell *cell = (WeedDetailTableViewCell *) [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    if (!cell.weed) {
        cell.delegate = self;
        [cell decorateCellWithWeed:weed parentViewController:self showHeader:false];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UserTableViewCell *cell = (UserTableViewCell *) [tableView dequeueReusableCellWithIdentifier:HEADER_CELL_REUSE_ID];
    Weed * weed = [self.weeds objectAtIndex:section];
    User *user = [[User alloc] init];
    user.id = weed.user_id;
    user.username = weed.username;
    user.user_type = weed.user_type;
    user.relationshipWithCurrentUser = weed.user_relationship_with_currentUser;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
    NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
    [cell decorateCellWithUser:user subtitle:formattedDateString];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [view setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return USER_TABLE_VIEW_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    Weed * weed = [self.weeds objectAtIndex:indexPath.section];
    NSNumber *height = [self.heights objectForKey:weed.id];
    return height? [height floatValue] : 0.0;
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
    
    if (needReload && [self.tableView.visibleCells containsObject:cell]) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (void)showUserViewController:(id)sender
{
//    [self performSegueWithIdentifier:@"showUser" sender:sender];
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
