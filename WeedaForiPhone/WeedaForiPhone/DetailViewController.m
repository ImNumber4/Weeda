//
//  DetailViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "DetailViewController.h"
#import "UserViewController.h"
#import "UserListViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setWeed:(Weed*)newDetailItem
{
    if (_weed != newDetailItem) {
        _weed = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.weed) {
        NSString *content = self.weed.content;
        NSString *username = self.weed.username;
        
        NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
        [self.userLabel setTitle:nameLabel forState:UIControlStateNormal];
        
        self.weedContentLabel.text = content;
        [self.weedContentLabel sizeToFit];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:self.weed.time];
        self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
        self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:7.0];
        
        [self.waterCount setTitle:[NSString stringWithFormat:@"%@ WATER DROPS", self.weed.water_count] forState:UIControlStateNormal];
        if([self.weed.water_count intValue] <= 0)
            [self.waterCount setEnabled:NO];
        
        
        [self.seedCount setTitle:[NSString stringWithFormat:@"%@ SEEDS", self.weed.seed_count] forState:UIControlStateNormal];
        if([self.weed.seed_count intValue] <= 0)
            [self.seedCount setEnabled:NO];
        
        if ([self.weed.if_cur_user_water_it intValue] == 1) {
            [self.waterDrop setImage:[self getImage:@"waterdrop.png" width:6 height:12] forState:UIControlStateNormal];
        } else {
            [self.waterDrop setImage:[self getImage:@"waterdropgray.png" width:6 height:12] forState:UIControlStateNormal];
        }
        if ([self.weed.if_cur_user_seed_it intValue] == 1) {
            [self.seed setImage:[self getImage:@"seed.png" width:18 height:9] forState:UIControlStateNormal];
        } else {
            [self.seed setImage:[self getImage:@"seedgray.png" width:18 height:9] forState:UIControlStateNormal];
        }
        
        [self.waterDrop removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.waterDrop addTarget:self action:@selector(waterIt:)forControlEvents:UIControlEventTouchDown];
        
        [self.seed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.seed addTarget:self action:@selector(seedIt:)forControlEvents:UIControlEventTouchDown];
        
    }
}

- (void)waterIt:(id) sender {
    Weed *weed = self.weed;
    if ([weed.if_cur_user_water_it intValue] == 1) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unwater/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] - 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:0];
            [self configureView];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/water/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] + 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:1];
            [self configureView];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    }
    
}

- (void)seedIt:(id) sender {
    Weed *weed = self.weed;
    if ([weed.if_cur_user_seed_it intValue] == 1) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unseed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] - 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:0];
            [self configureView];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/seed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] + 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:1];
            [self configureView];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Follow failed with error: %@", error);
        }];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUser"]) {
        [[segue destinationViewController] setUser_id:self.weed.user_id];
    } else if ([[segue identifier] isEqualToString:@"showWaterUser"]) {
        [[segue destinationViewController] setWater_weed_id:self.weed.id];
    } else if ([[segue identifier] isEqualToString:@"showSeedUser"]) {
        [[segue destinationViewController] setSeed_weed_id:self.weed.id];
    }
    
}

- (UIImage *)getImage:(NSString *)imageName width:(int)width height:(int) height
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}


@end
