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
#import "WeedBasicTableViewCell.h"
#import "TabBarController.h"
#import "AddWeedViewController.h"
#import "WeedImageController.h"
#import "WeedShowImageCell.h"
#import "WeedImageController.h"
#import "WeedImage.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define COLLECTION_VIEW_WIDTH 300
#define COLLECTION_VIEW_HEGITH 280
#define COLLECTION_VIEW_ACREAGE (COLLECTION_VIEW_WIDTH * COLLECTION_VIEW_HEGITH)

#define TEXTLABLE_WEED_CONTENT_ORIGIN_Y 59


const NSInteger PARENT_WEEDS_SECTION_INDEX = 0;
const NSInteger CURRENT_WEED_SECTION_INDEX = 1;
const NSInteger CURRENT_WEED_CONTROL_SECTION_INDEX = 2;
const NSInteger CHILD_WEEDS_SECTION_INDEX = 3;
const NSInteger PLACEHOLDER_SECTION_INDEX = 4;

const NSInteger SECTION_COUNT = 5;

const NSInteger WEED_CELL_HEIGHT = 50;
const NSInteger CURRENT_WEED_CONTROL_CELL_HEIGHT = 30;

const NSInteger SHOW_SEED_USERS = 1;
const NSInteger SHOW_WATER_USERS = 2;

const CGFloat COLLECTION_VIEW_PER_ROW_HEIGHT = 100.0;

const CGFloat COLLECTION_VIEW_HEIGHT = 300.0;

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    NSInteger *_ratio;
}

@property (nonatomic, retain) UICollectionView *imageCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchMetadataResultController;

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
        NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
        NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        for(Weed* weed in [mappingResult.array sortedArrayUsingDescriptors:descriptors]) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.lights addObject:weed];
            }
        }
        
//        [self.tableView reloadData];
        NSIndexSet *section = [NSIndexSet indexSetWithIndex:CHILD_WEEDS_SECTION_INDEX];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/getAncestorWeeds/%@", self.currentWeed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            for(Weed* weed in [mappingResult.array sortedArrayUsingDescriptors:descriptors]) {
                if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                    [self.parentWeeds addObject:weed];
                }
            }
            
            CGFloat orginalOffset = self.tableView.contentOffset.y;
            
            [self.tableView setContentOffset:CGPointMake(0, orginalOffset + self.parentWeeds.count * WEED_CELL_HEIGHT)];
//            [self.tableView reloadData];
            NSIndexSet *section = [NSIndexSet indexSetWithIndex:PARENT_WEEDS_SECTION_INDEX];
            [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
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
    } else if (section == PLACEHOLDER_SECTION_INDEX){
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
    } else if ([indexPath section] == PLACEHOLDER_SECTION_INDEX) {
        static NSString *CellIdentifier = @"PlaceHolderCell";
        UITableViewCell *cell = (WeedBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        Weed *weed = [self getWeed:indexPath];
        static NSString *CellIdentifier = @"WeedCell";
        WeedBasicTableViewCell *cell = (WeedBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self configureWeedTableViewCell:cell weed:weed];
        return cell;
    }
}

- (Weed *) getWeed:(NSIndexPath *)indexPath {
    Weed *weed;
    if ([indexPath section] == PARENT_WEEDS_SECTION_INDEX) {
        weed = self.parentWeeds[indexPath.row];
    } else if ([indexPath section] == CURRENT_WEED_SECTION_INDEX) {
        weed = self.currentWeed;
    } else {
        weed = self.lights[indexPath.row];
    }
    return weed;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CURRENT_WEED_SECTION_INDEX) {
        return [self getCurrentWeedCellHeight];
    } else if ([indexPath section] == CURRENT_WEED_CONTROL_SECTION_INDEX) {
        return CURRENT_WEED_CONTROL_CELL_HEIGHT;
    } else if ([indexPath section] == PLACEHOLDER_SECTION_INDEX) {
        CGFloat orginalOffset = self.tableView.contentOffset.y;
        CGFloat contentHeight = self.tableView.bounds.size.height - [self getCurrentWeedCellHeight] - (self.parentWeeds.count + self.lights.count) * WEED_CELL_HEIGHT + orginalOffset - TAB_BAR_HEIGHT- CURRENT_WEED_CONTROL_CELL_HEIGHT + 1;
        if (contentHeight > 0.0) {
            return contentHeight;
        }else{
            return 0.0;
        }
    } else {
        return WEED_CELL_HEIGHT;
    }
}

- (CGFloat)getCurrentWeedCellHeight {
    CGFloat textLableHeight = [self getTextLableHeight];
    
    //Add the height of the other UI elements inside your cell
    if (self.currentWeed.images.count > 0 && self.currentWeed.images.count < 3) {
        return TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 200.0 + 10;
    } else if (self.currentWeed.images.count >= 3) {
        return TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 250.0 + 10;
    } else {
        return TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 10;
    }
}

- (CGFloat)getTextLableHeight
{
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:12.0];
    temp.text = self.currentWeed.content;
    
    CGFloat textViewWidth = 200.0;
    CGRect tempFrame = CGRectMake(0, 0, textViewWidth, 40); //The height of this frame doesn't matter.
    CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.
    
    return MAX(tvsize.height, 40.0);
}

- (void)configureWeedDetailTableViewCell:(WeedDetailTableViewCell *)cell
{
    NSString *content = self.currentWeed.content;
    NSString *username = self.currentWeed.username;
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
    [cell.userLabel setTitle:nameLabel forState:UIControlStateNormal];
    [cell.userLabel addTarget:self action:@selector(showUser:)forControlEvents:UIControlEventTouchDown];
    
    cell.weedContentLabel.text = content;
    cell.weedContentLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [cell.weedContentLabel setFrame:CGRectMake(cell.weedContentLabel.frame.origin.x, cell.weedContentLabel.frame.origin.y, cell.weedContentLabel.frame.size.width, [self getTextLableHeight])];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.currentWeed.time];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    [cell.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:self.currentWeed.user_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    CALayer * l = [cell.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    
    [cell decorateCellWithWeed:self.currentWeed];
    
//    [self createImageCollectionViewCell:cell];
}

- (void)configureWeedTableViewCell:(WeedBasicTableViewCell *)cell weed:(Weed *)weed
{
    [cell decorateCellWithWeed:weed.content username:weed.username time:weed.time user_id:weed.user_id];
    [cell.usernameLabel removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.usernameLabel addTarget:self action:@selector(showUser:)forControlEvents:UIControlEventTouchDown];
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
}

- (void)configureWeedDetailControlTableViewCell:(WeedDetailControlTableViewCell *)cell
{
    [cell.waterCount setTitle:[NSString stringWithFormat:@"%@ WATER DROPS", self.currentWeed.water_count] forState:UIControlStateNormal];
    if([self.currentWeed.water_count intValue] <= 0)
        [cell.waterCount setEnabled:NO];
    else
        [cell.waterCount setEnabled:YES];
    cell.waterCount.tag = SHOW_WATER_USERS;
    [cell.waterCount removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.waterCount addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    
    [cell.seedCount setTitle:[NSString stringWithFormat:@"%@ SEEDS", self.currentWeed.seed_count] forState:UIControlStateNormal];
    if([self.currentWeed.seed_count intValue] <= 0)
        [cell.seedCount setEnabled:NO];
    else
        [cell.seedCount setEnabled:YES];
    cell.seedCount.tag = SHOW_SEED_USERS;
    [cell.seedCount removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.seedCount addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    
    [cell.lightCount setTitle:[NSString stringWithFormat:@"%@ LIGHTS", self.currentWeed.light_count] forState:UIControlStateNormal];
    [cell.lightCount setEnabled:NO];
    
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
    if ([self.currentWeed.if_cur_user_light_it intValue] == 1) {
        [cell.light setImage:[self getImage:@"light.png" width:14 height:12] forState:UIControlStateNormal];
    } else {
        [cell.light setImage:[self getImage:@"lightgray.png" width:14 height:12] forState:UIControlStateNormal];
    }
    
    [cell.waterDrop removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.waterDrop addTarget:self action:@selector(waterIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.seed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.seed addTarget:self action:@selector(seedIt:)forControlEvents:UIControlEventTouchDown];
    
    [cell.light removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.light addTarget:self action:@selector(lightIt:)forControlEvents:UIControlEventTouchDown];
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

-(void)lightIt:(id)sender {
    [self performSegueWithIdentifier:@"addWeed" sender:sender];
}

-(void)showUsers:(id)sender {
    NSString * feedUrl;
    if ([sender tag] == SHOW_WATER_USERS) {
        feedUrl = [NSString stringWithFormat:@"user/getUsersWaterWeed/%@", self.currentWeed.id];
    } else {
        feedUrl = [NSString stringWithFormat:@"user/getUsersSeedWeed/%@", self.currentWeed.id];
    }
    [[RKObjectManager sharedManager] getObjectsAtPath:feedUrl parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.users = mappingResult.array;
        [self performSegueWithIdentifier:@"showUsers" sender:sender];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
}

-(void)showUser:(id)sender {
    [self performSegueWithIdentifier:@"showUser" sender:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUser"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Weed* weed = [self getWeed:indexPath];
        [[segue destinationViewController] setUser_id:weed.user_id];
    } else if ([[segue identifier] isEqualToString:@"showUsers"]) {
        if ([sender tag] == SHOW_WATER_USERS) {
            [[segue destinationViewController] setTitle:@"Watered by"];
        } else {
            [[segue destinationViewController] setTitle:@"Seeded by"];
        }
        [[segue destinationViewController] setUsers:self.users];
    } else if ([[segue identifier] isEqualToString:@"addWeed"]) {
        UINavigationController* nav = [segue destinationViewController];
        AddWeedViewController* addWeedController = (AddWeedViewController *) nav.topViewController;
        [addWeedController setLightWeed:self.currentWeed];
    } else if ([[segue identifier] isEqualToString:@"showLight"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Weed *weed = [self getWeed:indexPath];
        [[segue destinationViewController] setCurrentWeed:weed];
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
