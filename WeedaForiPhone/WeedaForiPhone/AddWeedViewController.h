//
//  AddWeedViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddWeedViewController :  UIViewController

@property (nonatomic, retain) Weed * lightWeed;

+(void) presentControllerFrom:(UIViewController*) controller withWeed:(Weed*) weed;

@end
