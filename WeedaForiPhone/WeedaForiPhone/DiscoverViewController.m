//
//  DiscoverViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/6/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "DiscoverViewController.h"
#import "VendorMKAnnotationView.h"
#import "UserViewController.h"

@interface DiscoverViewController () <UITableViewDelegate, UITableViewDataSource, VendorMKAnnotationViewDelegate>

@property (nonatomic, strong) CLLocation *curLocation;

@end

@implementation DiscoverViewController

const NSInteger STORE_SEARCH = 0;
const NSInteger LOCATION_SEARCH = 1;

const double REGION_SPAN = 2.0;

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
    
    self.mapView.delegate = self;
    self.storeSearch.delegate = self;
    self.storeSearch.tag = STORE_SEARCH;
    self.location.delegate = self;
    self.location.tag = LOCATION_SEARCH;
    self.suggestions = [[NSMutableArray alloc] init];
    [self.storeSearch setImage:[UIImage imageNamed: @"search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchInCurrentLocation addTarget:self action:@selector(searchInCurrentLocation:)forControlEvents:UIControlEventTouchDown];
    self.searchInCurrentLocation.backgroundColor = [ColorDefinition blueColor];
    [self.searchInArea addTarget:self action:@selector(searchInArea:)forControlEvents:UIControlEventTouchDown];
    self.searchInArea.backgroundColor = [ColorDefinition greenColor];
    [self.storeSearch becomeFirstResponder];
    [self searchInCurrentLocation:nil];
    self.geocoder = [[CLGeocoder alloc] init];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.mapView addGestureRecognizer:singleFingerTap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [self hideSuggestionList];
    [self enableSearchButton:self.storeSearch];
    [self enableSearchButton:self.location];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) enableSearchButton:(UISearchBar *)searchBar {
    UITextField *searchBarTextField = nil;
    for (UIView *mainview in searchBar.subviews)
    {
        for (UIView *subview in mainview.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)subview;
                break;
            }
            
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.location endEditing:YES];
    [self.storeSearch endEditing:YES];
}

- (void)searchInArea:(id) sender
{
    [self updateStores:self.mapView.region];
}

- (void)searchInCurrentLocation:(id) sender
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
        NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
        if (order == NSOrderedSame || order == NSOrderedDescending) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.delegate = self; // we set the delegate of locationManager to self.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
        [self.locationManager startUpdatingLocation];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.location.hidden = YES;
    self.locationBackground.hidden = YES;
    [self hideSuggestionList];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.location.hidden = NO;
    self.locationBackground.hidden = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
    if ([self.location.text isEqualToString: @""]) {
        [self searchInCurrentLocation:nil];
    } else {
        [self.geocoder geocodeAddressString:self.location.text
                      completionHandler:^(NSArray* placemarks, NSError* error){
                          if (placemarks && placemarks.count > 0) {
                              CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                              [self updateRegionAndStores:placeMark.location.coordinate];
                              self.curLocation = placeMark.location;
                          } else {
                              UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Sorry, we couldn't locate the place specified by you. Please make sure you enter correct address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                              [errorAlert show];
                          }
                      }
         ];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchBar.tag == LOCATION_SEARCH) {
        NSString *location = searchText;
        [self.geocoder geocodeAddressString:location
                     completionHandler:^(NSArray* placemarks, NSError* error){
                         [self hideSuggestionList];
                         if (placemarks && placemarks.count > 0) {
                             for (CLPlacemark *placeMark in placemarks) {
                                 NSString *address = @"";
                                 for (NSString *subAddress in [placeMark.addressDictionary objectForKey:@"FormattedAddressLines"]){
                                     address = [address stringByAppendingString:subAddress];
                                     address = [address stringByAppendingString:@", "];
                                 }
                                 [self.suggestions addObject:[address substringToIndex:address.length - 2]];
                             }
                             [self showSuggestionList:LOCATION_SEARCH];
                         }
                     }
         ];
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect keyboardFrameInWindowsCoordinates;
    [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindowsCoordinates];
    CGPoint kbPosition = keyboardFrameInWindowsCoordinates.origin;
    [self.suggestionList setFrame:CGRectMake(self.suggestionList.frame.origin.x, self.suggestionList.frame.origin.y, self.suggestionList.frame.size.width, kbPosition.y - self.suggestionList.frame.origin.y)];
}

- (void) showSuggestionList: (NSInteger) target {
    self.suggestionList.hidden = NO;
    self.suggestionList.tag = target;
    [self.suggestionList reloadData];
}

- (void) hideSuggestionList {
    self.suggestionList.hidden = YES;
    [self.suggestions removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Failed to retrieve your location. Please make sure you have internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    self.locationManager = nil;
    NSLog(@"Error: %@", error.description);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"User";
    if ([annotation isKindOfClass:[User class]]) {
        VendorMKAnnotationView *annotationView = (VendorMKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[VendorMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.delegate = self;
        } else {
            [annotationView setAnnotation:annotation];
        }
        return annotationView;
    }
    
    return nil;
}

- (void) annotationPressed:(MKAnnotationView *)annotationView {
    if ([annotationView.annotation isKindOfClass:[User class]]) {
        [self performSegueWithIdentifier:@"showUser" sender:((User *) annotationView.annotation).id];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    self.curLocation = [locations lastObject];
    [self.location setText:@""];
    [self updateRegionAndStores:self.curLocation.coordinate];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.curLocation != nil &&
        self.curLocation.coordinate.latitude > self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta &&
        self.curLocation.coordinate.latitude < self.mapView.region.center.latitude + self.mapView.region.span.latitudeDelta &&
        self.curLocation.coordinate.longitude > self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta &&
        self.curLocation.coordinate.longitude < self.mapView.region.center.longitude + self.mapView.region.span.longitudeDelta) {
        [self.location setImage:[UIImage imageNamed: @"current_location.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    } else {
        [self.location setImage:[UIImage imageNamed: @"current_location_gray.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }
    //[self updateStores];
}

- (void)updateRegionAndStores: (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D zoomLocation= coordinate;
    MKCoordinateSpan span;
    if (self.mapView.region.span.latitudeDelta > REGION_SPAN) {
        span = MKCoordinateSpanMake(REGION_SPAN, REGION_SPAN);
    } else {
        span = self.mapView.region.span;
    }
    MKCoordinateRegion region = MKCoordinateRegionMake(zoomLocation, span);
    [self.mapView setRegion:region animated:YES];
    [self updateStores:region];
}

- (void)updateStores: (MKCoordinateRegion) region
{
    NSString * feedUrl = [NSString stringWithFormat:@"user/queryUsersWithCoordinates/%f/%f/%f/%@", region.center.latitude, region.center.longitude, fmax(region.span.latitudeDelta, region.span.longitudeDelta), self.storeSearch.text];
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
    NSString *suggestion = [self.suggestions objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:12.0]];
    [cell.textLabel setText:suggestion];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *suggestion = [self.suggestions objectAtIndex:indexPath.row];
    if (self.suggestionList.tag == LOCATION_SEARCH) {
        [self.location setText:suggestion];
    }
    [self hideSuggestionList];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUser"]) {
        [ [segue destinationViewController] setUser_id:sender];
    }
}

@end
