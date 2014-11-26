//
//  WeedControlView.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedControlView.h"
#import "ImageUtil.h"
#import "MasterViewController.h"
#import "AddWeedViewController.h"
#import "UserListViewController.h"
#import "UIViewHelper.h"
#import "WLActionSheet.h"

@interface WeedControlView() <UIAlertViewDelegate>
@property (nonatomic, strong) Weed *weed;
@property (nonatomic, strong) UIViewController *parentViewController;
@end

@implementation WeedControlView

static double PADDING = 5;
static double LABEL_WIDTH = 70;
static double SIMPLE_MODE_LABEL_WIDTH = 30;
static double LABEL_HEIGHT = 14;

static double LIGHT_ICON_HEIGHT = 14;
static double LIGHT_ICON_WIDTH = 16;
static double SEED_ICON_WIDTH = 24;
static double SEED_ICON_HEIGHT = 12;
static double WATER_ICON_WIDTH = 7;
static double WATER_ICON_HEIGHT = 14;
static double FONT_SIZE = 10;

static double DELETE_ICON_WIDTH = 15;
static double DELETE_ICON_HEIGHT = 15;

static NSInteger SHOW_SEED_USERS = 1;
static NSInteger SHOW_WATER_USERS = 2;

- (instancetype)initWithFrame:(CGRect)frame isSimpleMode:(BOOL)isSimpleMode
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isSimpleMode = isSimpleMode;
        double frameWidth = frame.size.width;
        double frameHeight = frame.size.height;
        double section1CenterX = frameWidth / 6.0;
        double section2CenterX = frameWidth * 0.5;
        double section3CenterX = frameWidth * 5.0 / 6.0;
        double centerY = frameHeight/2.0;
        
        double labelWidth = LABEL_WIDTH;
        if (isSimpleMode) {
            labelWidth = SIMPLE_MODE_LABEL_WIDTH;
        }
        
        self.light = [[UIButton alloc] initWithFrame:CGRectMake(section1CenterX - (LIGHT_ICON_WIDTH + PADDING + labelWidth)/2.0, centerY - LIGHT_ICON_HEIGHT/2.0, LIGHT_ICON_WIDTH, LIGHT_ICON_HEIGHT)];
        [self addSubview:self.light];
        self.seed = [[UIButton alloc] initWithFrame:CGRectMake(section2CenterX - (SEED_ICON_WIDTH + PADDING + labelWidth)/2.0, centerY - SEED_ICON_HEIGHT/2.0, SEED_ICON_WIDTH, SEED_ICON_HEIGHT)];
        [self addSubview:self.seed];
        self.waterDrop = [[UIButton alloc] initWithFrame:CGRectMake(section3CenterX - (WATER_ICON_WIDTH + PADDING + labelWidth)/2.0, centerY - WATER_ICON_HEIGHT/2.0 - 2, WATER_ICON_WIDTH, WATER_ICON_HEIGHT)];
        [self addSubview:self.waterDrop];
        
        self.lightCount = [[UIButton alloc] initWithFrame:CGRectMake(section1CenterX + (LIGHT_ICON_WIDTH + PADDING - labelWidth)/2.0, centerY - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT)];
        [self.lightCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.lightCount.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:self.lightCount];
        self.lightCount.enabled = !isSimpleMode;
        
        self.seedCount = [[UIButton alloc] initWithFrame:CGRectMake(section2CenterX + (SEED_ICON_WIDTH + PADDING - labelWidth)/2.0, centerY - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT)];
        [self.seedCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.seedCount.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:self.seedCount];
        self.seedCount.enabled = !isSimpleMode;
        
        self.waterCount = [[UIButton alloc] initWithFrame:CGRectMake(section3CenterX + (WATER_ICON_WIDTH + PADDING - labelWidth)/2.0, centerY - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT)];
        [self.waterCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.waterCount.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:self.waterCount];
        self.waterCount.enabled = !isSimpleMode;
        
        self.deleteWeed = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - DELETE_ICON_WIDTH - PADDING * 2, centerY - DELETE_ICON_HEIGHT / 2.0, DELETE_ICON_WIDTH, DELETE_ICON_HEIGHT)];
        [self addSubview:self.deleteWeed];
    }
    return self;
}

- (void)updateSubViewFrameWithWidth:(double)width
{
    double frameWidth = width;
    double frameHeight = self.frame.size.height;
    double section1CenterX = frameWidth / 6.0;
    double section2CenterX = frameWidth * 0.5;
    double section3CenterX = frameWidth * 5.0 / 6.0;
    double centerY = frameHeight / 2.0;
    
    double labelWidth = LABEL_WIDTH;
    if (_isSimpleMode) {
        labelWidth = SIMPLE_MODE_LABEL_WIDTH;
    }
    
    self.light.frame = CGRectMake(section1CenterX - (LIGHT_ICON_WIDTH + PADDING + labelWidth)/2.0, centerY - LIGHT_ICON_HEIGHT/2.0, LIGHT_ICON_WIDTH, LIGHT_ICON_HEIGHT);
    self.seed.frame = CGRectMake(section2CenterX - (SEED_ICON_WIDTH + PADDING + labelWidth)/2.0, centerY - SEED_ICON_HEIGHT/2.0, SEED_ICON_WIDTH, SEED_ICON_HEIGHT);
    self.waterDrop.frame = CGRectMake(section3CenterX - (WATER_ICON_WIDTH + PADDING + labelWidth)/2.0, centerY - WATER_ICON_HEIGHT/2.0 - 2, WATER_ICON_WIDTH, WATER_ICON_HEIGHT);
    self.lightCount.frame = CGRectMake(section1CenterX + (LIGHT_ICON_WIDTH + PADDING - labelWidth)/2.0, centerY - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT);
    self.seedCount.frame = CGRectMake(section2CenterX + (SEED_ICON_WIDTH + PADDING - labelWidth)/2.0, centerY - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT);
    self.waterCount.frame = CGRectMake(section3CenterX + (WATER_ICON_WIDTH + PADDING - labelWidth)/2.0, centerY - LABEL_HEIGHT/2.0, labelWidth, LABEL_HEIGHT);
}

- (void) decorateWithWeed:(Weed *) weed parentViewController:(UIViewController *) parentViewController
{
    _weed = weed;
    _parentViewController = parentViewController;
    [self updateView];
}

- (void) updateView
{
    [self.waterCount setTitle:[NSString stringWithFormat:(self.isSimpleMode? @"%@" : @"%@ DROPS"), [UIViewHelper getCountString:_weed.water_count]] forState:UIControlStateNormal];
    if([_weed.water_count intValue] <= 0)
        [self.waterCount setEnabled:NO];
    else
        [self.waterCount setEnabled:YES];
    self.waterCount.tag = SHOW_WATER_USERS;
    if (!self.isSimpleMode) {
        [self.waterCount removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.waterCount addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    }
    
    [self.seedCount setTitle:[NSString stringWithFormat:(self.isSimpleMode? @"%@" : @"%@ SEEDS"), [UIViewHelper getCountString:_weed.seed_count]] forState:UIControlStateNormal];
    if([_weed.seed_count intValue] <= 0)
        [self.seedCount setEnabled:NO];
    else
        [self.seedCount setEnabled:YES];
    self.seedCount.tag = SHOW_SEED_USERS;
    if (!self.isSimpleMode) {
        [self.seedCount removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.seedCount addTarget:self action:@selector(showUsers:)forControlEvents:UIControlEventTouchDown];
    }
    
    [self.lightCount setTitle:[NSString stringWithFormat:(self.isSimpleMode? @"%@" : @"%@ LIGHTS"), [UIViewHelper getCountString:_weed.light_count]] forState:UIControlStateNormal];
    [self.lightCount setEnabled:NO];
    
    if ([_weed.if_cur_user_water_it intValue] == 1) {
        [self.waterDrop setBackgroundImage:[WeedControlView getWaterIcon] forState:UIControlStateNormal];
    } else {
        [self.waterDrop setBackgroundImage:[WeedControlView getGrayWaterIcon] forState:UIControlStateNormal];
    }
    if ([_weed.if_cur_user_seed_it intValue] == 1) {
        [self.seed setBackgroundImage:[WeedControlView getSeedIcon] forState:UIControlStateNormal];
    } else {
        [self.seed setBackgroundImage:[WeedControlView getGraySeedIcon] forState:UIControlStateNormal];
    }
    if ([_weed.if_cur_user_light_it intValue] == 1) {
        [self.light setBackgroundImage:[WeedControlView getLightIcon] forState:UIControlStateNormal];
    } else {
        [self.light setBackgroundImage:[WeedControlView getGrayLightIcon] forState:UIControlStateNormal];
    }
    [self.deleteWeed setBackgroundImage:[WeedControlView getGrayDeleteIcon] forState:UIControlStateNormal];
    
    [self.waterDrop removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.waterDrop addTarget:self action:@selector(waterIt:)forControlEvents:UIControlEventTouchDown];
    
    [self.seed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.seed addTarget:self action:@selector(seedIt:)forControlEvents:UIControlEventTouchDown];
    
    [self.light removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.light addTarget:self action:@selector(lightIt:)forControlEvents:UIControlEventTouchDown];
    
    [self.deleteWeed removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.deleteWeed addTarget:self action:@selector(deleteIt:) forControlEvents:UIControlEventTouchDown];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (_weed.user_id != appDelegate.currentUser.id) {
        self.deleteWeed.hidden = YES;
    } else {
        [self updateSubViewFrameWithWidth:(self.frame.size.width - CGRectGetWidth(self.deleteWeed.frame) - PADDING)];
    }
}

- (void)waterIt:(id) sender {
    Weed *weed = _weed;
    if ([weed.if_cur_user_water_it intValue] == 1) {
        weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] - 1];
        weed.if_cur_user_water_it = [NSNumber numberWithInt:0];
        [self updateView];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unwater/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unwater failed with error: %@", error);
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] + 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:1];
            [self updateView];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to unwater weed. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [av show];
        }];
    } else {
        weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] + 1];
        weed.if_cur_user_water_it = [NSNumber numberWithInt:1];
        [self updateView];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/water/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"water failed with error: %@", error);
            weed.water_count = [NSNumber numberWithInt:[weed.water_count intValue] - 1];
            weed.if_cur_user_water_it = [NSNumber numberWithInt:0];
            [self updateView];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to water weed. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [av show];
        }];
    }
}

- (void)seedIt:(id) sender {
    Weed *weed = _weed;
    if ([weed.if_cur_user_seed_it intValue] == 1) {
        weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] - 1];
        weed.if_cur_user_seed_it = [NSNumber numberWithInt:0];
        [self updateView];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/unseed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unseed failed with error: %@", error);
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] + 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:1];
            [self updateView];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to unseed weed. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [av show];
        }];
    } else {
        weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] + 1];
        weed.if_cur_user_seed_it = [NSNumber numberWithInt:1];
        [self updateView];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"weed/seed/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"seed failed with error: %@", error);
            weed.seed_count = [NSNumber numberWithInt:[weed.seed_count intValue] - 1];
            weed.if_cur_user_seed_it = [NSNumber numberWithInt:0];
            [self updateView];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to seed weed. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [av show];
        }];
    }
}

-(void)showUsers:(id)sender {
    NSString * feedUrl;
    [sender setEnabled:false];
    NSString * title;
    if ([sender tag] == SHOW_WATER_USERS) {
        feedUrl = [NSString stringWithFormat:@"user/getUsersWaterWeed/%@", _weed.id];
        title = @"Watered By";
    } else {
        feedUrl = [NSString stringWithFormat:@"user/getUsersSeedWeed/%@", _weed.id];
        title = @"Seeded By";
    }
    [[RKObjectManager sharedManager] getObjectsAtPath:feedUrl parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        UserListViewController* viewController = [[UserListViewController alloc] initWithNibName:nil bundle:nil];
        [viewController setUsers:mappingResult.array];
        viewController.title = title;
        [self.parentViewController.navigationController pushViewController:viewController animated:YES];
        [sender setEnabled:true];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [sender setEnabled:true];
    }];
}

-(void)lightIt:(id)sender {
    [AddWeedViewController presentControllerFrom:_parentViewController withWeed:_weed];
}

- (void)deleteIt:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Delete Weed"
                                                 message:@"Are you sure to delete this weed?"
                                                delegate:self
                                       cancelButtonTitle:@"cancel"
                                       otherButtonTitles:@"delete", nil];
    [av show];
}

+ (UIImage *) getLightIcon
{
    return [UIImage imageNamed:@"light.png"];
}

+ (UIImage *) getGrayLightIcon
{
    return [ImageUtil colorImage:[WeedControlView getLightIcon] color:[ColorDefinition grayColor]];
}

+ (UIImage *) getSeedIcon
{
    return [UIImage imageNamed:@"seed.png"];
}

+ (UIImage *) getGraySeedIcon
{
    return [ImageUtil colorImage:[WeedControlView getSeedIcon] color:[ColorDefinition grayColor]];
}

+ (UIImage *) getWaterIcon
{
    return [UIImage imageNamed:@"waterdrop.png"];
}

+ (UIImage *) getGrayWaterIcon
{
    return [UIImage imageNamed:@"waterdropgray.png"];
}

+ (UIImage *) getGrayDeleteIcon
{
    return [UIImage imageNamed:@"delete_weed.png"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *clickButtonStr = [alertView buttonTitleAtIndex:buttonIndex];
    if ([clickButtonStr isEqualToString:@"delete"]) {
        [self deleteWeedEntity:_weed];
    }
}

- (void)deleteWeedEntity:(Weed *)weed
{
    [[RKObjectManager sharedManager] deleteObject:weed path:[NSString stringWithFormat:@"weed/delete/%@", weed.id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Response: %@", mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving post: %@", error.localizedDescription);
    }];
    
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    [objectStore.mainQueueManagedObjectContext deleteObject:weed];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlView:didDeletedWeed:)]) {
        [self.delegate controlView:self didDeletedWeed:weed];
    }
}

@end
