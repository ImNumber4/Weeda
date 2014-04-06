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
        RKLogInfo(@"Load complete: Table should refresh...");
        User *user = [mappingResult.array objectAtIndex:0];
        self.userNameLabel.text = user.username;
        self.userEmailLabel.text = user.email;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. yyyy"];
        NSString *formattedDateString = [dateFormatter stringFromDate:user.time];
        self.timeLabel.text = [NSString stringWithFormat:@"Memeber since: %@", formattedDateString];
        
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
