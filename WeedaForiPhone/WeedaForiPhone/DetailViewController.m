//
//  DetailViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "DetailViewController.h"
#import "UserViewController.h"
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
const NSInteger SHOW_SEED_USERS = 1;
const NSInteger SHOW_WATER_USERS = 2;

const CGFloat COLLECTION_VIEW_PER_ROW_HEIGHT = 100.0;

const CGFloat COLLECTION_VIEW_HEIGHT = 300.0;

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextViewDelegate, WeedBasicTableViewCellDelegate, WeedDetailTableViewCellDelegate> {
    NSInteger *_ratio;
}

@property (nonatomic, retain) UICollectionView *imageCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchMetadataResultController;
@property (nonatomic, weak) WeedDetailTableViewCell *detailCell;
@property (nonatomic) CGFloat detailWeedCellHeight;

//@property (nonatomic, retain) UIView *statusBarBackground;

@end

@implementation DetailViewController

static NSString * WEED_DETAIL_TABLE_CELL_REUSE_ID = @"WeedDetailCell";
static NSString * WEED_BASIC_TABLE_CELL_REUSE_ID = @"WeedBasicCell";
static NSString * WEED_PLACEHOLDER_CELL_REUSE_ID = @"PlaceHolderCell";
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
    [self.tableView registerClass:[WeedBasicTableViewCell class] forCellReuseIdentifier:WEED_BASIC_TABLE_CELL_REUSE_ID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:WEED_PLACEHOLDER_CELL_REUSE_ID];
    
    if (self.currentWeed) {
        self.currentWeedId = self.currentWeed.id;
    }
    //always try to pull for the lastest content
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/queryById/%@", self.currentWeedId]  parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if ([mappingResult.array count]) {
            Weed * weed = mappingResult.array[0];
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                self.currentWeed = weed;
                NSIndexSet *section = [NSIndexSet indexSetWithIndex:CURRENT_WEED_SECTION_INDEX];
                [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
            } else {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry, weed has been deleted." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Failed to query weed by id due to error: %@", error);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to get weed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [self loadLights];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:UIWindowDidBecomeHiddenNotification object:self.view.window];
}

- (void) loadLights
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/getLights/%@", self.currentWeedId] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
        NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        [self.lights removeAllObjects];
        for(Weed* weed in [mappingResult.array sortedArrayUsingDescriptors:descriptors]) {
            if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                [self.lights addObject:weed];
            }
        }
        
        NSIndexSet *section = [NSIndexSet indexSetWithIndex:CHILD_WEEDS_SECTION_INDEX];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/getAncestorWeeds/%@", self.currentWeedId] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self.parentWeeds removeAllObjects];
            for(Weed* weed in [mappingResult.array sortedArrayUsingDescriptors:descriptors]) {
                if (weed.shouldBeDeleted != nil && [weed.shouldBeDeleted intValue] == 0) {
                    [self.parentWeeds addObject:weed];
                }
            }
            
            CGFloat orginalOffset = self.tableView.contentOffset.y;
            
            [self.tableView setContentOffset:CGPointMake(0, orginalOffset + self.parentWeeds.count * [WeedBasicTableViewCell getCellHeight])];
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

- (void)selectWeedContent:(UIGestureRecognizer *)recognizer
{
    //do not do anything
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
        return self.currentWeed ? 1 : 0;
    } else if (section == PLACEHOLDER_SECTION_INDEX){
        return 1;
    } else {
        return self.lights.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == CURRENT_WEED_SECTION_INDEX) {
        if (!self.detailCell) {
            self.detailCell = (WeedDetailTableViewCell *) [tableView dequeueReusableCellWithIdentifier:WEED_DETAIL_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
            [self configureWeedDetailTableViewCell:self.detailCell];
            self.detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            [self.detailCell refreshControlDataWithWeed:self.currentWeed];
        }
        return self.detailCell;
    } else if ([indexPath section] == PLACEHOLDER_SECTION_INDEX) {
        UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:WEED_PLACEHOLDER_CELL_REUSE_ID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        Weed *weed = [self getWeed:indexPath];
        WeedBasicTableViewCell *cell = (WeedBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:WEED_BASIC_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] != CURRENT_WEED_SECTION_INDEX && [indexPath section] != PLACEHOLDER_SECTION_INDEX) {
        Weed *weed = [self getWeed:indexPath];
        DetailViewController *controller = [[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        [controller setCurrentWeed:weed];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CURRENT_WEED_SECTION_INDEX) {
        return [self getHeightForCurrentWeed];
    } else if ([indexPath section] == PLACEHOLDER_SECTION_INDEX) {
        CGFloat orginalOffset = self.tableView.contentOffset.y;
        CGFloat contentHeight = self.tableView.bounds.size.height - (self.currentWeed?[self getHeightForCurrentWeed]:0) - (self.parentWeeds.count + self.lights.count) * [WeedBasicTableViewCell getCellHeight] + orginalOffset - self.tabBarController.tabBar.frame.size.height + 1;
        if (contentHeight > 0.0) {
            return contentHeight;
        }else{
            return 0.0;
        }
    } else {
        return [WeedBasicTableViewCell getCellHeight];
    }
}

- (CGFloat) getHeightForCurrentWeed
{
    if (_detailWeedCellHeight) {
        return _detailWeedCellHeight;
    } else {
        return [WeedDetailTableViewCell heightForCell:self.currentWeed showHeader:YES];
    }
    return _detailWeedCellHeight;
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
    [cell decorateCellWithWeed:self.currentWeed parentViewController:self showHeader:true];
    cell.delegate = self;
}

- (void)configureWeedTableViewCell:(WeedBasicTableViewCell *)cell weed:(Weed *)weed
{
    [cell decorateCellWithContent:weed.content username:weed.username time:weed.time user_id:weed.user_id user_type:weed.user_type];
    cell.delegate = self;
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
}

- (void) showUser:(id) sender
{
    [self showUserViewController:sender];
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

- (void)tableViewCell:(WeedDetailTableViewCell *)cell height:(CGFloat)height needReload:(BOOL)needReload
{
    _detailWeedCellHeight = height;
    if (needReload) {
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

- (void)didFinishDeleteCell
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
