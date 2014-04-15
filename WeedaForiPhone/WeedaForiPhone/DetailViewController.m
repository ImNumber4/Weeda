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
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:nameLabel];
        NSInteger nameLength=[username length] + 1;
        NSInteger totalLength=[nameLabel length];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:9.0f] range:NSMakeRange(0, totalLength)];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:10.0f] range:NSMakeRange(0, nameLength)];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, totalLength)];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, nameLength)];
        [self.userLabel setAttributedTitle:attString forState:UIControlStateNormal];
        
        self.weedContentLabel.text = [NSString stringWithFormat:@"%@", content];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. dd yyyy"];
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
