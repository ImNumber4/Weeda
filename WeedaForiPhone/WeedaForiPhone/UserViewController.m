//
//  UserViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@property (nonatomic, retain) User * user;

@end

@implementation UserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/query/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeFollowButton
{
    [self.followButton setTitle:@"+Follow" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [UIColor colorWithRed:105.0/255.0 green:210.0/255.0 blue:245.0/255.0 alpha:1];
    [self.followButton addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton
{
    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
    self.followButton.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:250.0/255.0 blue:117.0/255.0 alpha:1];
    [self.followButton addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateView
{
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    self.userEmailLabel.text = self.user.email;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.user.time];
    self.timeLabel.text = [NSString stringWithFormat:@"Memeber since: %@", formattedDateString];
    self.weedCountLabel.text = [NSString stringWithFormat:@"%@", self.user.weedCount];
    self.followerCountLabel.text = [NSString stringWithFormat:@"%@", self.user.followerCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%@", self.user.followingCount];
    if ([self.user.relationshipWithCurrentUser intValue] == 0) {
        self.followButton.hidden = TRUE;
    } else if ([self.user.relationshipWithCurrentUser intValue] < 3){
        [self makeFollowButton];
    } else {
        [self makeFollowingButton];
    }
}


- (void)follow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)unfollow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.user = [mappingResult.array objectAtIndex:0];
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

@end
