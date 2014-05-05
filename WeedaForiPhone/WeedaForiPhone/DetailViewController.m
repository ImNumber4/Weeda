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
#import "WeedDetailControlTableViewCell.h"
#import "WeedDetailTableViewCell.h"
#import "WeedTableViewCell.h"
#import "TabBarController.h"

const NSInteger PARENT_WEEDS_SECTION_INDEX = 0;
const NSInteger CURRENT_WEED_SECTION_INDEX = 1;
const NSInteger CURRENT_WEED_CONTROL_SECTION_INDEX = 2;
const NSInteger CHILD_WEEDS_SECTION_INDEX = 3;

const NSInteger SECTION_COUNT = 4;

const NSInteger WEED_CELL_HEIGHT = 55;


@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.parentWeeds = [[NSMutableArray alloc] init];
    self.lights = [[NSMutableArray alloc] init];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/getLights/%@", self.currentWeed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        for(Weed* weed in mappingResult.array) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.lights addObject:weed];
            }
        }
        [self.tableView reloadData];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/getAncestorWeeds/%@", self.currentWeed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
            NSArray *descriptors=[NSArray arrayWithObject: descriptor];
            NSArray *orderedArray=[mappingResult.array sortedArrayUsingDescriptors:descriptors];
            
            for(Weed* weed in orderedArray) {
                if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                    [self.parentWeeds addObject:weed];
                }
            }
            
            
            CGFloat orginalOffset = self.tableView.contentOffset.y;
            [self.tableView reloadData];
            [self.tableView setContentOffset:CGPointMake(0, orginalOffset + self.parentWeeds.count * WEED_CELL_HEIGHT)];
            CGFloat contentHeight = self.tableView.bounds.size.height + self.parentWeeds.count * WEED_CELL_HEIGHT + orginalOffset - TAB_BAR_HEIGHT + 1;
            if (self.tableView.contentSize.height > contentHeight) {
                contentHeight = self.tableView.contentSize.height;
            }
            [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width, contentHeight)];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"getAncestorWeeds failed with error: %@", error);
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"getLights failed with error: %@", error);
    }];
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == PARENT_WEEDS_SECTION_INDEX) {
        return self.parentWeeds.count;
    } else if (section == CURRENT_WEED_SECTION_INDEX) {
        return 1;
    } else if (section == CURRENT_WEED_CONTROL_SECTION_INDEX) {
        return 1;
    } else {
        return self.lights.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == CURRENT_WEED_SECTION_INDEX) {
        static NSString *CellIdentifier = @"WeedDetailCell";
        WeedDetailTableViewCell *cell = (WeedDetailTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self configureWeedDetailTableViewCell:cell];
        return cell;
    } else if ([indexPath section] == CURRENT_WEED_CONTROL_SECTION_INDEX) {
        static NSString *CellIdentifier = @"WeedDetailControlCell";
        WeedDetailControlTableViewCell *cell = (WeedDetailControlTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self configureWeedDetailControlTableViewCell:cell];
        return cell;
    } else {
        Weed *weed;
        if ([indexPath section] == PARENT_WEEDS_SECTION_INDEX) {
            weed = self.parentWeeds[indexPath.row];
        } else {
            weed = self.lights[indexPath.row];
        }
        static NSString *CellIdentifier = @"WeedCell";
        WeedTableViewCell *cell = (WeedTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self configureWeedTableViewCell:cell weed:weed];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == CURRENT_WEED_SECTION_INDEX) {
    
        UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)]; //This initial size doesn't matter
        temp.font = [UIFont systemFontOfSize:12.0];
        temp.text = self.currentWeed.content;
    
        CGFloat textViewWidth = 200.0;
        CGRect tempFrame = CGRectMake(0, 0, textViewWidth, 50); //The height of this frame doesn't matter.
        CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.
    
        //Add the height of the other UI elements inside your cell
        return MAX(tvsize.height, 50.0) + 50.0;
    } else if ([indexPath section] == CURRENT_WEED_CONTROL_SECTION_INDEX) {
        return 30;
    } else {
        return WEED_CELL_HEIGHT;
    }
}


- (void)configureWeedDetailTableViewCell:(WeedDetailTableViewCell *)cell
{
    NSString *content = self.currentWeed.content;
    NSString *username = self.currentWeed.username;
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
    [cell.userLabel setTitle:nameLabel forState:UIControlStateNormal];
    
    cell.weedContentLabel.text = content;
    [cell.weedContentLabel sizeToFit];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.currentWeed.time];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    cell.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

- (void)configureWeedTableViewCell:(WeedTableViewCell *)cell weed:(Weed *)weed
{
    cell.weedContentLabel.text = [NSString stringWithFormat:@"%@", weed.content];
    [cell.weedContentLabel sizeToFit];
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", weed.username];
    [cell.usernameLabel setTitle:nameLabel forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    cell.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
}

- (void)configureWeedDetailControlTableViewCell:(WeedDetailControlTableViewCell *)cell
{
    [cell.waterCount setTitle:[NSString stringWithFormat:@"%@ WATER DROPS", self.currentWeed.water_count] forState:UIControlStateNormal];
    if([self.currentWeed.water_count intValue] <= 0)
        [cell.waterCount setEnabled:NO];
    else
        [cell.waterCount setEnabled:YES];
    
    
    [cell.seedCount setTitle:[NSString stringWithFormat:@"%@ SEEDS", self.currentWeed.seed_count] forState:UIControlStateNormal];
    if([self.currentWeed.seed_count intValue] <= 0)
        [cell.seedCount setEnabled:NO];
    else
        [cell.seedCount setEnabled:YES];
    
    
    if ([self.currentWeed.if_cur_user_water_it intValue] == 1) {
        [cell.waterDrop setImage:[self getImage:@"waterdrop.png" width:6 height:12] forState:UIControlStateNormal];
    } else {
        [cell.waterDrop setImage:[self getImage:@"waterdropgray.png" width:6 height:12] forState:UIControlStateNormal];
    }
    if ([self.currentWeed.if_cur_user_seed_it intValue] == 1) {
        [cell.seed setImage:[self getImage:@"seed.png" width:18 height:9] forState:UIControlStateNormal];
    } else {
        [cell.seed setImage:[self getImage:@"seedgray.png" width:18 height:9] forState:UIControlStateNormal];
    }
    [cell.light setImage:[self getImage:@"light.png" width:14 height:12] forState:UIControlStateNormal];
    
    [cell.waterDrop removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.waterDrop addTarget:self action:@selector(waterIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.seed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.seed addTarget:self action:@selector(seedIt:)forControlEvents:UIControlEventTouchDown];
    [cell.lights setSeparatorColor:[UIColor clearColor]];
}

- (void)waterIt:(id) sender {
    Weed *weed = self.currentWeed;
    if ([weed.if_cur_user_water_it intValue] == 1) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unwater/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] - 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:0];
            [self reloadWeedControlCell];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unwater failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/water/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] + 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:1];
            [self reloadWeedControlCell];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"water failed with error: %@", error);
        }];
    }
    
}

- (void)reloadWeedControlCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:CURRENT_WEED_CONTROL_SECTION_INDEX];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)seedIt:(id) sender {
    Weed *weed = self.currentWeed;
    if ([weed.if_cur_user_seed_it intValue] == 1) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unseed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] - 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:0];
            [self reloadWeedControlCell];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unseed failed with error: %@", error);
        }];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/seed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] + 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:1];
            [self reloadWeedControlCell];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"seed failed with error: %@", error);
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUser"]) {
        [[segue destinationViewController] setUser_id:self.currentWeed.user_id];
    } else if ([[segue identifier] isEqualToString:@"showWaterUser"]) {
        [[segue destinationViewController] setWater_weed_id:self.currentWeed.id];
    } else if ([[segue identifier] isEqualToString:@"showSeedUser"]) {
        [[segue destinationViewController] setSeed_weed_id:self.currentWeed.id];
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
