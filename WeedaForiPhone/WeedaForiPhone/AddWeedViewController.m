//
//  AddWeedViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "AddWeedViewController.h"
#import <RestKit/RestKit.h>

@interface AddWeedViewController ()

@end

@implementation AddWeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.title = @"Add weed";
}

#pragma mark -
#pragma mark Save and Cancel
- (IBAction) save: (id) sender {
    
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    Weed *weed = [NSEntityDescription insertNewObjectForEntityForName:@"Weed" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    weed.id = [NSNumber numberWithInt:-1];
    weed.username = self.currentUser.username;
    weed.user_id = self.currentUser.id;
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    weed.content = self.weedContentView.text;
    weed.time = [NSDate date];
    
    [[RKObjectManager sharedManager] postObject:weed path:@"weed/create" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Response: %@", mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving post: %@", error.localizedDescription);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
