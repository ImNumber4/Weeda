//
//  ChangePasswordViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/24/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface ChangePasswordViewController ()

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) UILabel* noticeLabel;
@property (nonatomic, retain) UIButton* submitButton;
@property (nonatomic, retain) NSString* currentPassword;
@property (nonatomic, retain) NSString* updatedPassword;
@property (nonatomic, retain) NSString* verifyPassword;

@end

@implementation ChangePasswordViewController

static NSString * TABLE_CELL_REUSE_ID = @"ChangePasswordTableCell";

static const double TABLE_CELL_HEIGHT = 50.0;
static const double HORIZONTAL_PADDING = 10.0;
static const double VERTICAL_PADDING = 50.0;
static const double TOP_PADDING = 30.0;
static const double CORNER_RADIUS = 5.0;
static const double FONT_SIZE = 12.0;

static const NSInteger TABLE_CELL_COUNT = 3;

//Adding more options, needs to bump up TABLE_CELL_COUNT accordingly
static const NSInteger CURRENT_PASSWORD_INDEX = 0;
static const NSInteger NEW_PASSWORD_INDEX = 1;
static const NSInteger VERIFY_NEW_PASSWORD_INDEX = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Change Password";
    self.view.backgroundColor = [SettingsViewController settingViewBackgroundColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    double tableY = TOP_PADDING + statusBarSize.height;
    if (self.navigationController) {
        tableY += self.navigationController.navigationBar.frame.size.height;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, tableY, self.view.frame.size.width, TABLE_CELL_HEIGHT * TABLE_CELL_COUNT)];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UserInfoEditableCell class] forCellReuseIdentifier:TABLE_CELL_REUSE_ID];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [SettingsViewController decorateSettingViewStyleTable:self.tableView];
    
    self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING,self.tableView.frame.origin.y + self.tableView.frame.size.height, self.view.frame.size.width - 2 * HORIZONTAL_PADDING, VERTICAL_PADDING)];
    [self.noticeLabel setFont:[UIFont systemFontOfSize:11.0]];
    [self.noticeLabel setTintColor:[UIColor lightGrayColor]];
    self.noticeLabel.numberOfLines = 2;
    [self.view addSubview:self.noticeLabel];
    
    self.submitButton = [[UIButton alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, VERTICAL_PADDING + self.tableView.frame.origin.y + self.tableView.frame.size.height, self.view.frame.size.width - 2 * HORIZONTAL_PADDING, 30)];
    [self.view addSubview:self.submitButton];
    self.submitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.submitButton.layer.cornerRadius = CORNER_RADIUS;
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.backgroundColor = [ColorDefinition greenColor];
    self.submitButton.layer.cornerRadius = CORNER_RADIUS;
    [self.submitButton addTarget:self action:@selector(submit:)forControlEvents:UIControlEventTouchDown];
}

- (void) viewDidAppear:(BOOL)animated
{
    [((UserInfoEditableCell *)[[self.tableView visibleCells] objectAtIndex:0]).contentTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TABLE_CELL_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoEditableCell *cell = (UserInfoEditableCell *)[tableView dequeueReusableCellWithIdentifier:TABLE_CELL_REUSE_ID forIndexPath:indexPath];
    if (cell) {
        cell.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.contentTextField.secureTextEntry = YES;
        [cell adjustNameLabelWidth:110];
        switch (indexPath.row) {
            case CURRENT_PASSWORD_INDEX:
                cell.nameLabel.text = @"Current Password";
                cell.contentTextField.text = self.currentPassword;
                [cell.contentTextField becomeFirstResponder];
                break;
            case NEW_PASSWORD_INDEX:
                cell.nameLabel.text = @"New Password";
                cell.contentTextField.text = self.updatedPassword;
                break;
            case VERIFY_NEW_PASSWORD_INDEX:
                cell.nameLabel.text = @"Verify Password";
                cell.contentTextField.text = self.verifyPassword;
                break;
            default:
                return nil;
        }
    }
    
    return cell;
}

- (void) contentDidChange:(NSString *)text sender:(UserInfoEditableCell *) sender
{
    CGPoint cellPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPosition];
    switch (indexPath.row) {
        case CURRENT_PASSWORD_INDEX:
            self.currentPassword = text;
            break;
        case NEW_PASSWORD_INDEX:
            self.updatedPassword = text;
            break;
        case VERIFY_NEW_PASSWORD_INDEX:
            self.verifyPassword = text;
            break;
        default:
            break;
    }
}

- (void) finishModifying:(NSString *)text sender:(UserInfoEditableCell *)sender {}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (void)submit:(id) sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (!(self.currentPassword && [self.currentPassword isEqualToString:appDelegate.currentUser.password])) {
        self.noticeLabel.text = @"Current password is not correct.";
        return;
    }
    if (!(self.updatedPassword && self.verifyPassword && [self.updatedPassword isEqualToString:self.verifyPassword])) {
        self.noticeLabel.text = @"New password and verify password should be identical and non empty.";
        return;
    }
    if ([self.updatedPassword isEqualToString:self.currentPassword]) {
        self.noticeLabel.text = @"New password is the same as current password.";
        return;
    }
    NSString * passwordInvalidReason = [User validatePassword:self.updatedPassword];
    if (passwordInvalidReason != nil) {
        self.noticeLabel.text = passwordInvalidReason;
        return;
    }
    self.noticeLabel.text = @"";
//    self.submitButton.enabled = false;
//    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/updateUsername/%@",self.updatedUsername] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        self.submitButton.enabled = true;
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        [appDelegate populateCurrentUserFromCookie];
//        [self.tableView reloadData];
//        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"Your username has successfully been updated to be %@.",self.updatedUsername] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [errorAlert show];
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Failed to update username with error: %@", error);
//        self.submitButton.enabled = true;
//        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"We can not change your username to be %@ since it has already been taken. Please use a different name or try again later. ",self.updatedUsername] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [errorAlert show];
//    }];
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
