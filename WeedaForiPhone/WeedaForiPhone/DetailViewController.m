//
//  DetailViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        NSString *content = [[self.detailItem valueForKey:@"content"] description];
        NSString *username = [[self.detailItem valueForKey:@"username"] description];
        NSString *email = [[self.detailItem valueForKey:@"email"] description];
        self.userLabel.text = [NSString stringWithFormat:@"%@(%@)", username, email];
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@", content];
        self.detailDescriptionLabel.font = [UIFont systemFontOfSize:10.0];
        self.detailDescriptionLabel.numberOfLines=5;
        self.userLabel.font = [UIFont systemFontOfSize:8.0 ];
        self.userLabel.textColor = [UIColor grayColor];

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

@end
