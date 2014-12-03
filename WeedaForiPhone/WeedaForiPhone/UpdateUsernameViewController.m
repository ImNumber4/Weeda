//
//  UpdateUsernameViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/24/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UpdateUsernameViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface UpdateUsernameViewController ()

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) UILabel* noticeLabel;
@property (nonatomic, retain) UIButton* submitButton;
@property (nonatomic, retain) NSString* updatedUsername;

@end

@implementation UpdateUsernameViewController

static NSString * TABLE_CELL_REUSE_ID = @"UpdateUsernameTableCell";

static const double TABLE_CELL_HEIGHT = 50.0;
static const double HORIZONTAL_PADDING = 10.0;
static const double VERTICAL_PADDING = 50.0;
static const double TOP_PADDING = 30.0;
static const double CORNER_RADIUS = 5.0;
static const double FONT_SIZE = 12.0;

static const NSInteger TABLE_CELL_COUNT = 1;

//Adding more options, needs to bump up TABLE_CELL_COUNT accordingly
static const NSInteger UPDATE_USERNAME_INDEX = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Update Username";
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
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        switch (indexPath.row) {
            case UPDATE_USERNAME_INDEX:
                cell.nameLabel.text = @"Username";
                cell.contentTextField.text = appDelegate.currentUser.username;
                cell.contentTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.contentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.contentTextField.placeholder = appDelegate.currentUser.username;
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
    if (indexPath.row == UPDATE_USERNAME_INDEX) {
        self.updatedUsername = text;
        NSString * usernameInvalidReason = [User validateUsername:self.updatedUsername];
        if (usernameInvalidReason) {
            self.noticeLabel.text = usernameInvalidReason;
        } else {
            self.noticeLabel.text = nil;
        }
    }
}

- (void) finishModifying:(NSString *)text sender:(UserInfoEditableCell *)sender {}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (void)submit:(id) sender
{
    NSString * usernameInvalidReason = [User validateUsername:self.updatedUsername];
    if (usernameInvalidReason) {
        self.noticeLabel.text = usernameInvalidReason;
        return;
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (!self.updatedUsername || [self.updatedUsername isEqualToString:appDelegate.currentUser.username]) {
        self.noticeLabel.text = @"New username should be non-empty and different from previous username.";
        return;
    }
    self.submitButton.enabled = false;
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/updateUsername/%@",self.updatedUsername] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.submitButton.enabled = true;
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate populateCurrentUserFromCookie];
        [self.tableView reloadData];
        [self.view endEditing:true];
        self.noticeLabel.text = [NSString stringWithFormat:@"Your username has successfully been updated to be %@.",self.updatedUsername];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Failed to update username with error: %@", error);
        self.submitButton.enabled = true;
        self.noticeLabel.text = [NSString stringWithFormat:@"We can't change username to be %@ since it has already been taken. Please use a different name or try again later. ",self.updatedUsername];
    }];
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
