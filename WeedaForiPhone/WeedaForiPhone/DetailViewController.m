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
#import "WeedDetailTableViewCell.h"
#import "WeedBasicTableViewCell.h"
#import "TabBarController.h"
#import "AddWeedViewController.h"
#import "WeedImageController.h"
#import "WeedShowImageCell.h"
#import "WeedImageController.h"
#import "WeedImage.h"
#import "WLWebViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define COLLECTION_VIEW_WIDTH 300
#define COLLECTION_VIEW_HEGITH 280
#define COLLECTION_VIEW_ACREAGE (COLLECTION_VIEW_WIDTH * COLLECTION_VIEW_HEGITH)

#define TEXTLABLE_WEED_CONTENT_ORIGIN_Y 59


const NSInteger PARENT_WEEDS_SECTION_INDEX = 0;
const NSInteger CURRENT_WEED_SECTION_INDEX = 1;
const NSInteger CHILD_WEEDS_SECTION_INDEX = 2;
const NSInteger PLACEHOLDER_SECTION_INDEX = 3;

const NSInteger SECTION_COUNT = 4;

const NSInteger WEED_CELL_HEIGHT = 50;

const NSInteger SHOW_SEED_USERS = 1;
const NSInteger SHOW_WATER_USERS = 2;

const CGFloat COLLECTION_VIEW_PER_ROW_HEIGHT = 100.0;

const CGFloat COLLECTION_VIEW_HEIGHT = 300.0;

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextViewDelegate, WeedDetailTableViewCellDelegate> {
    NSInteger *_ratio;
}

@property (nonatomic, retain) UICollectionView *imageCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchMetadataResultController;

@property (nonatomic) CGFloat detailWeedCellHeight;

//@property (nonatomic, retain) UIView *statusBarBackground;

@end

@implementation DetailViewController

static NSString * WEED_DETAIL_TABLE_CELL_REUSE_ID = @"WeedDetailCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    _statusBarBackground.backgroundColor = [ColorDefinition greenColor];
//    [self.view addSubview:_statusBarBackground];
    
//    _statusBarBackground.translatesAutoresizingMaskIntoConstraints = NO;
//    NSDictionary *vs = NSDictionaryOfVariableBindings(_statusBarBackground);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_statusBarBackground(20)]" options:0 metrics:nil views:vs]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_statusBarBackground]|" options:0 metrics:nil views:vs]];
    
    self.parentWeeds = [[NSMutableArray alloc] init];
    self.lights = [[NSMutableArray alloc] init];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerClass:[WeedDetailTableViewCell class] forCellReuseIdentifier:WEED_DETAIL_TABLE_CELL_REUSE_ID];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/getLights/%@", self.currentWeed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
        NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        for(Weed* weed in [mappingResult.array sortedArrayUsingDescriptors:descriptors]) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.lights addObject:weed];
            }
        }
        
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
            NSIndexSet *section = [NSIndexSet indexSetWithIndex:PARENT_WEEDS_SECTION_INDEX];
            [UIView setAnimationsEnabled:NO];
            [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
            [UIView setAnimationsEnabled:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"getAncestorWeeds failed with error: %@", error);
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"getLights failed with error: %@", error);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:UIWindowDidBecomeHiddenNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *cells = [self.tableView visibleCells];
    for (UITableViewCell *cell in cells) {
        if ([cell isKindOfClass:[WeedDetailTableViewCell class]]) {
            WeedDetailTableViewCell *detailCell = (WeedDetailTableViewCell *)cell;
            [detailCell cellWillDisappear];
        }
    }
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
    } else if (section == PLACEHOLDER_SECTION_INDEX){
        return 1;
    } else {
        return self.lights.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == CURRENT_WEED_SECTION_INDEX) {
        WeedDetailTableViewCell *cell = (WeedDetailTableViewCell *) [tableView dequeueReusableCellWithIdentifier:WEED_DETAIL_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
        [self configureWeedDetailTableViewCell:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if ([indexPath section] == PLACEHOLDER_SECTION_INDEX) {
        static NSString *CellIdentifier = @"PlaceHolderCell";
        UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        Weed *weed = [self getWeed:indexPath];
        static NSString *CellIdentifier = @"WeedCell";
        WeedBasicTableViewCell *cell = (WeedBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self configureWeedTableViewCell:cell weed:weed];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        return _detailWeedCellHeight;
    } else if ([indexPath section] == PLACEHOLDER_SECTION_INDEX) {
        CGFloat orginalOffset = self.tableView.contentOffset.y;
        CGFloat contentHeight = self.tableView.bounds.size.height - _detailWeedCellHeight - (self.parentWeeds.count + self.lights.count) * WEED_CELL_HEIGHT + orginalOffset - self.tabBarController.tabBar.frame.size.height + 1;
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
    cell.delegate = self;
    [cell decorateCellWithWeed:self.currentWeed parentViewController:self showHeader:true];
}

- (void)configureWeedTableViewCell:(WeedBasicTableViewCell *)cell weed:(Weed *)weed
{
    [cell decorateCellWithWeed:weed.content username:weed.username time:weed.time user_id:weed.user_id];
    [cell.usernameLabel removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.usernameLabel addTarget:self action:@selector(showUser:)forControlEvents:UIControlEventTouchDown];
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
}

- (void)showUserViewController:(id)sender
{
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

#pragma tablecell Delegate
- (BOOL)pressURL:(NSURL *)url
{
    NSLog(@"Click url: %@", url);
    
    WLWebViewController *webViewController = [[WLWebViewController alloc]init];
    webViewController.url = url;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:webViewController animated:NO];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBarController.tabBar.alpha = 0.0;
    }];
    
    return NO;
}

- (void)tableViewCell:(WeedDetailTableViewCell *)cell height:(CGFloat)height needReload:(BOOL)needReload
{
    _detailWeedCellHeight = height;
    if (needReload && [self.tableView.visibleCells containsObject:cell]) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)exitFullScreen:(NSNotification *)notification
{
//    CGRect navigationFrame =  self.navigationController.navigationBar.frame;
//    NSLog(@"navigation bar: %f-%f-%f-%f", navigationFrame.origin.x, navigationFrame.origin.y, CGRectGetWidth(navigationFrame), CGRectGetHeight(navigationFrame));
//    navigationFrame.size.height = 64;
//    self.navigationController.navigationBar.frame = navigationFrame;
//    [self setNeedsStatusBarAppearanceUpdate];
}

@end
