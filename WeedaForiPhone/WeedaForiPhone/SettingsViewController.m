//
//  SettingsViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/22/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "WelcomeViewController.h"

@interface SettingsViewController ()

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) UIButton* logoutButton;

@end

@implementation SettingsViewController

static NSString * TABLE_CELL_REUSE_ID = @"SettingTableCell";

static const double TABLE_CELL_HEIGHT = 50.0;
static const double HORIZONTAL_PADDING = 10.0;
static const double VERTICAL_PADDING = 30.0;
static const double TOP_PADDING = 30.0;
static const double CORNER_RADIUS = 5.0;
static const double FONT_SIZE = 12.0;

static const NSInteger TABLE_CELL_COUNT = 4;

//Adding more options, needs to bump up TABLE_CELL_COUNT accordingly
static const NSInteger UPDATE_USERNAME_INDEX = 0;
static const NSInteger CHANGE_PASS_WORD_INDEX = 1;
static const NSInteger TERMS_AND_POLICIES_INDEX = 2;
static const NSInteger ABOUT_INDEX = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    self.view.backgroundColor = [SettingsViewController settingViewBackgroundColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    double tableY = TOP_PADDING + statusBarSize.height;
    if (self.navigationController) {
        tableY += self.navigationController.navigationBar.frame.size.height;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, tableY, self.view.frame.size.width, TABLE_CELL_HEIGHT * TABLE_CELL_COUNT)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [SettingsViewController decorateSettingViewStyleTable:self.tableView];
    
    self.tableView.scrollEnabled = false;
    
    self.logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, VERTICAL_PADDING + self.tableView.frame.origin.y + self.tableView.frame.size.height, self.view.frame.size.width - 2 * HORIZONTAL_PADDING, 30)];
    [self.view addSubview:self.logoutButton];
    self.logoutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.logoutButton.layer.cornerRadius = CORNER_RADIUS;
    [self.logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    [self.logoutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
    self.logoutButton.backgroundColor = [UIColor redColor];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.logoutButton.layer.backgroundColor = [UIColor redColor].CGColor;
    self.logoutButton.layer.cornerRadius = CORNER_RADIUS;
    [self.logoutButton addTarget:self action:@selector(logout:)forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (UIColor *) settingViewBackgroundColor
{
    return [UIColor colorWithWhite:0.95 alpha:1.0];
}

+ (void) decorateSettingViewStyleTableCell:(UITableViewCell *) cell
{
    [cell.textLabel setFont: [UIFont boldSystemFontOfSize:FONT_SIZE]];
    [cell.detailTextLabel setFont: [UIFont systemFontOfSize:FONT_SIZE]];
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

+ (void) decorateSettingViewStyleTable:(UITableView *) tableView
{
    tableView.contentInset = UIEdgeInsetsZero;
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    tableView.tableFooterView = [[UIView alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TABLE_CELL_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_CELL_REUSE_ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TABLE_CELL_REUSE_ID];
        [SettingsViewController decorateSettingViewStyleTableCell:cell];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    cell.detailTextLabel.text = nil;
    switch (indexPath.row) {
        case UPDATE_USERNAME_INDEX:
            cell.textLabel.text = @"Update Username";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",  appDelegate.currentUser.username];
            break;
        case CHANGE_PASS_WORD_INDEX:
            cell.textLabel.text = @"Change Password";
            break;
        case TERMS_AND_POLICIES_INDEX:
            cell.textLabel.text = @"Terms & Policies";
            break;
        case ABOUT_INDEX:
            cell.textLabel.text = @"About";
            break;
        default:
            return nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case UPDATE_USERNAME_INDEX:
            [self performSegueWithIdentifier:@"updateUsernameView" sender:self];
            break;
        case CHANGE_PASS_WORD_INDEX:
            [self performSegueWithIdentifier:@"changePasswordView" sender:self];
            break;
        case TERMS_AND_POLICIES_INDEX:
            [self performSegueWithIdentifier:@"termAndPoliciesView" sender:self];
            break;
        case ABOUT_INDEX:
            [self performSegueWithIdentifier:@"aboutView" sender:self];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (void)logout:(id) sender
{
    // Dispose of any resources that can be recreated.
     AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate signoutFrom:self];
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
