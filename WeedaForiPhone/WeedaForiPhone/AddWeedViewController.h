//
//  AddWeedViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface AddWeedViewController :  UIViewController
@property (weak, nonatomic) IBOutlet UITextView *weedContentView;


- (IBAction) save: (id) sender;
- (IBAction) cancel: (id) sender;

@end
