//
//  AboutViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/24/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "AboutViewController.h"
#import "SettingsViewController.h"

@interface AboutViewController ()

@property (nonatomic, retain) UITableView* tableView;

@end

@implementation AboutViewController

static NSString * TABLE_CELL_REUSE_ID = @"AboutTableCell";

static const double TABLE_CELL_HEIGHT = 50.0;
static const double VERTICAL_PADDING = 30.0;
static const double TOP_PADDING = 30.0;

static const NSInteger TABLE_CELL_COUNT = 1;

//Adding more options, needs to bump up TABLE_CELL_COUNT accordingly
static const NSInteger VERSION_INDEX = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"About";
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    double tableY =  TOP_PADDING + statusBarSize.height;
    if (self.navigationController) {
        tableY += self.navigationController.navigationBar.frame.size.height;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, tableY, self.view.frame.size.width, TABLE_CELL_HEIGHT * TABLE_CELL_COUNT)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [SettingsViewController decorateSettingViewStyleTable:self.tableView];
    self.tableView.scrollEnabled = false;
    
    UILabel * copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, tableY + self.tableView.frame.size.height + VERTICAL_PADDING, self.view.frame.size.width, 30)];
    copyrightLabel.text = @"Copyright @ 2015 Cannablaze, Inc";
    copyrightLabel.textColor = [UIColor grayColor];
    [copyrightLabel setFont:[UIFont systemFontOfSize:12]];
    [copyrightLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:copyrightLabel];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_CELL_REUSE_ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TABLE_CELL_REUSE_ID];
        [SettingsViewController decorateSettingViewStyleTableCell:cell];
    }
    cell.detailTextLabel.text = nil;
    switch (indexPath.row) {
        case VERSION_INDEX:
            cell.textLabel.text = @"Version";
            cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            break;
        default:
            return nil;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
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
