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
        
        NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
        [self.userLabel setTitle:nameLabel forState:UIControlStateNormal];
        
        self.weedContentLabel.text = content;
        [self.weedContentLabel sizeToFit];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:self.weed.time];
        self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
        self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:7.0];
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
