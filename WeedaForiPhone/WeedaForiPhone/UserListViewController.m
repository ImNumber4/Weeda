//
//  UserListViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserListViewController.h"
#import "UserTableViewCell.h"
#import "UserViewController.h"

@interface UserListViewController ()
@end

@implementation UserListViewController 

static NSString * USER_TABLE_CELL_REUSE_ID = @"UserTableCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_TABLE_CELL_REUSE_ID];
    if (self.users && [self.users count] > 0) {
        [self loadData];
    } else if (self.urlPathToPullUsers) {
        UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
        [self refreshView:self.refreshControl];
    }
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading data..."];
    [self fetachData];
}

- (void)fetachData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:self.urlPathToPullUsers parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self setUsers:mappingResult.array];
        [self loadData];
        [self.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load %@ failed with error: %@", self.urlPathToPullUsers, error);
        [self.refreshControl endRefreshing];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to get users. Please pull to try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [av show];
    }];
}

- (void)loadData
{
    [self.tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
    if (cell) {
        User *user = [self.users objectAtIndex:indexPath.row];
        [self decorateCellWithUser:user cell:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.users objectAtIndex:indexPath.row];
    UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
    [controller setUser_id:user.id];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)decorateCellWithUser:(User *)user cell:(UserTableViewCell *)cell {
    [cell decorateCellWithUser:user];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return USER_TABLE_VIEW_CELL_HEIGHT;
}

@end
