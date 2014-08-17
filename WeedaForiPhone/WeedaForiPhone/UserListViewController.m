//
//  UserListViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserListViewController.h"
#import "UserTableViewCell.h"
#import "WeedImageController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserListViewController ()
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
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self loadData];
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
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableCell" forIndexPath:indexPath];
    User *user = [self.users objectAtIndex:indexPath.row];
    [self decorateCellWithUser:user cell:cell];
    
    return cell;
}

- (void)decorateCellWithUser:(User *)user cell:(UserTableViewCell *)cell {
    [cell.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:user.id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", user.username];
    cell.usernameLabel.text = nameLabel;
    if ([user.relationshipWithCurrentUser intValue] == 0) {
        cell.followButton.hidden = TRUE;
    } else if ([user.relationshipWithCurrentUser intValue] < 3){
        [self makeFollowButton:cell.followButton];
    } else {
        [self makeFollowingButton:cell.followButton];
    }
}


- (void)makeFollowButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    //blue
    button.backgroundColor = [ColorDefinition blueColor];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"followed.png"] forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    //green
    button.backgroundColor = [ColorDefinition greenColor];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)follow:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    User *user = [self.users objectAtIndex:indexPath.row];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", user.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        user.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationshipWithCurrentUser;
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)unfollow:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    User *user = [self.users objectAtIndex:indexPath.row];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", user.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        user.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationshipWithCurrentUser;
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUser"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        User *user = [self.users objectAtIndex:indexPath.row];
        [[segue destinationViewController] setUser_id:user.id];
    }
}

@end
