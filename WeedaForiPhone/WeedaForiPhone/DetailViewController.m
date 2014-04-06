//
//  DetailViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "DetailViewController.h"
#import "UserViewController.h"

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
        NSString *username = self.weed.user.username;
        NSString *email = self.weed.user.email;
        [self.userLabel setTitle:[NSString stringWithFormat:@"%@(%@)", username, email] forState:UIControlStateNormal];
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@", content];
        self.detailDescriptionLabel.numberOfLines=5;
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
        [[segue destinationViewController] setUser_id:self.weed.user.id];
        [[segue destinationViewController] setCurrentUser:self.currentUser];
    }
}


@end
