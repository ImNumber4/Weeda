//
//  UserListViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation UserListViewController 

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
    
    
    [self loadData];
}

- (void)loadData
{
    
    // Load the object model via RestKit
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getUsersWaterWeed/%@", self.water_weed_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        RKLogInfo(@"Load complete: Table should refresh...");
        self.users = mappingResult.array;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableCell" forIndexPath:indexPath];
    User *user = [self.users objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = user.username;
    return cell;
}

@end
