//
//  WeedControlView.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeedControlView : UIView

@property (strong, nonatomic) UIButton *waterCount;
@property (strong, nonatomic) UIButton *seedCount;
@property (nonatomic, strong) UIButton *seed;
@property (nonatomic, strong) UIButton *waterDrop;
@property (nonatomic, strong) UIButton *light;
@property (nonatomic, strong) UIButton *lightCount;
@property (nonatomic, strong) UITableView *lights;
@property (nonatomic) BOOL isSimpleMode;

- (instancetype)initWithFrame:(CGRect)frame isSimpleMode:(BOOL)isSimpleMode;
- (void) decorateWithWeed:(Weed *) weed parentViewController:(UIViewController *) parentViewController;

@end
