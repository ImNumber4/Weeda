//
//  DiscoverViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/6/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "DiscoverViewController.h"
#import "VendorMKAnnotationView.h"

@interface DiscoverViewController ()

@end

@implementation DiscoverViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.mapView.delegate = self;
    self.locationManager.delegate = self; // we set the delegate of locationManager to self.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Failed to retrieve your location. Please make sure you have internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"User";
    if ([annotation isKindOfClass:[User class]]) {
        VendorMKAnnotationView *annotationView = (VendorMKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[VendorMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            
        } else {
            [annotationView setAnnotation:annotation];
        }
        return annotationView;
    }
    
    return nil;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *crnLoc = [locations lastObject];
    CLLocationCoordinate2D zoomLocation= crnLoc.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 3000, 3000);
    NSString * feedUrl = [NSString stringWithFormat:@"user/queryUsersWithCoordinates/%f/%f/2", crnLoc.coordinate.latitude, crnLoc.coordinate.longitude];
    [[RKObjectManager sharedManager] getObjectsAtPath:feedUrl parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            [self.mapView removeAnnotation:annotation];
        }
        for (User * user in mappingResult.array) {
            [self.mapView addAnnotation:user];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    [self.mapView setRegion:viewRegion animated:YES];
    
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
