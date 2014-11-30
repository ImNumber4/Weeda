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
#import "ImageUtil.h"

@interface UserListViewController () <UISearchBarDelegate>
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, copy) NSArray *filteredUsers;
@property (nonatomic, copy) NSMutableDictionary *sortedUsers;
@property (nonatomic, copy) NSMutableDictionary *sortedAndFilteredUsers;
@property (nonatomic, retain) UIBarButtonItem * searchButton;
@property (nonatomic, retain) UIBarButtonItem * cancelButton;
@end

@implementation UserListViewController 

static NSString * USER_TABLE_CELL_REUSE_ID = @"UserTableCell";
static double SECTION_HEADER_HEIGHT = 20;

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
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.hidden = true;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translucent = true;
    self.searchBar.delegate = self;
    [self.searchBar setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon.png"] color:[UIColor whiteColor]] atSize:CGSizeMake(10, 10)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self setSearchBarTextColorToBeWhite];
    self.searchButton = [[UIBarButtonItem alloc] initWithImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon.png"] color:[UIColor whiteColor]] atSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchBar:)];
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchBar:)];
    [self.navigationItem setRightBarButtonItem:self.searchButton];
}

-(void)displaySearchBar:(id)sender {
    if (self.searchBar.hidden) {
        self.navigationItem.titleView = self.searchBar;
        self.searchBar.hidden = false;
        [self.searchBar setAlpha:0.0];
        [self.navigationItem setHidesBackButton:YES animated:NO];
        [self.navigationItem setRightBarButtonItem:self.cancelButton];
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self.searchBar becomeFirstResponder];
        }];
    } else {
        [self.navigationItem setHidesBackButton:NO animated:NO];
        [self.navigationItem setRightBarButtonItem:self.cancelButton];
        [self.searchBar resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.navigationItem.titleView = nil;
            self.searchBar.hidden = true;
            self.searchBar.text = @"";
            [self.tableView reloadData];
            [self.navigationItem setRightBarButtonItem:self.searchButton];
        }];
    }
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

#pragma searchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:TRUE];
    [self reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar endEditing:TRUE];
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
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to get users. Please pull to try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
}

- (void)loadData
{
    self.sortedUsers = [self buildDictionaryFromArray:self.users];
    [self reloadData];
}

- (void)reloadData
{
    [self filterUsers];
    self.sortedAndFilteredUsers = [self buildDictionaryFromArray:self.filteredUsers];
    [self.tableView reloadData];
}

- (void) filterUsers
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchBar.text]];
    self.filteredUsers = [self.users filteredArrayUsingPredicate:predicate];
}

- (NSMutableDictionary *) buildDictionaryFromArray:(NSArray *)array
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    for (User* user in array) {
        if (![dictionary objectForKey:user.user_type]) {
            [dictionary setObject:[NSMutableArray new] forKey:user.user_type];
        }
        NSMutableArray * arrayForType = [dictionary objectForKey:user.user_type];
        [arrayForType addObject:user];
    }
    for (NSString *userType in [dictionary allKeys]) {
        NSArray *sortedArray;
        sortedArray = [[dictionary objectForKey:userType] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(User*)a username];
            NSString *second = [(User*)b username];
            return [first compare:second];
        }];
        [dictionary setObject:sortedArray forKey:userType];
    }
    return dictionary;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self getUsersToDisplay] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [ColorDefinition lightGreenColor];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, self.tableView.frame.size.width - 10, SECTION_HEADER_HEIGHT);
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    NSDictionary *userDictionary = [self getUsersToDisplay];
    label.text = [[userDictionary allKeys] objectAtIndex:section];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *userDictionary = [self getUsersToDisplay];
    NSString * userType = [[userDictionary allKeys] objectAtIndex:section];
    return [[userDictionary objectForKey:userType] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
    if (cell) {
        NSDictionary *userDictionary = [self getUsersToDisplay];
        NSString * userType = [[userDictionary allKeys] objectAtIndex:indexPath.section];
        User *user = [[userDictionary objectForKey:userType] objectAtIndex:indexPath.row];
        [self decorateCellWithUser:user cell:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *userDictionary = [self getUsersToDisplay];
    NSString * userType = [[userDictionary allKeys] objectAtIndex:indexPath.section];
    User *user = [[userDictionary objectForKey:userType] objectAtIndex:indexPath.row];
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

- (NSDictionary *) getUsersToDisplay
{
    if (self.searchBar.hidden) {
        return self.sortedUsers;
    } else {
        return self.sortedAndFilteredUsers;
    }
}

@end
