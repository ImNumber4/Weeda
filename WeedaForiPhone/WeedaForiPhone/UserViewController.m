//
//  UserViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/5/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/query/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *user = [mappingResult.array objectAtIndex:0];
        self.userNameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
        self.userEmailLabel.text = user.email;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. yyyy"];
        NSString *formattedDateString = [dateFormatter stringFromDate:user.time];
        self.timeLabel.text = [NSString stringWithFormat:@"Memeber since: %@", formattedDateString];
        self.weedCountLabel.text = [NSString stringWithFormat:@"%@", user.weedCount];
        self.followerCountLabel.text = [NSString stringWithFormat:@"%@", user.followerCount];
        self.followingCountLabel.text = [NSString stringWithFormat:@"%@", user.followingCount];
        if ([user.relationshipWithCurrentUser intValue] == 0) {
            self.followButton.hidden = TRUE;
        } else if ([user.relationshipWithCurrentUser intValue] < 3){
            [self.followButton setTitle:@"+Follow" forState:UIControlStateNormal];
        } else {
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
