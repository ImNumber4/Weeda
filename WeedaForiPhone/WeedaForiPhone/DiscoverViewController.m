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
#import "UserTableViewCell.h"

@interface DiscoverViewController () <UITableViewDelegate, UITableViewDataSource, VendorMKAnnotationViewDelegate>

@property (nonatomic, strong) CLLocation *curLocation;
@property BOOL isListViewOn;
@property BOOL isFilterOn;
@property (nonatomic, strong) UITableView * storeList;
@property (nonatomic, strong) UIButton *filterIcon;
@property (nonatomic, strong) UIButton *listIcon;
@property (strong) CLLocationManager *locationManager;
@property (strong) CLGeocoder *geocoder;
@property (strong) NSMutableArray *locations;
@property (strong) NSMutableArray *stores;

@end

@implementation DiscoverViewController

const NSInteger STORE_SEARCH = 0;
const NSInteger LOCATION_SEARCH = 1;

const double REGION_SPAN = 2.0;
const double ICON_HEIGHT = 28.0;
const double ICON_PADDING = 5.0;

const NSInteger LOCATION_LIST_TABLE_VIEW = 1;
const NSInteger STORE_LIST_TABLE_VIEW = 2;

const double LOCATION_LIST_HEIGHT = 35;

static NSString * LOCATION_LIST_CELL_REUSE_ID = @"LocationCell";
static NSString * STORE_LIST_CELL_REUSE_ID = @"StoreCell";

const double STORE_LIST_ANIMATION_VERTICAL_DELTA = 50;

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
    self.locationSearch.delegate = self;
    self.locationSearch.tag = LOCATION_SEARCH;
    self.locations = [[NSMutableArray alloc] init];
    [self.storeSearch setImage:[UIImage imageNamed: @"search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchInCurrentLocation addTarget:self action:@selector(searchInCurrentLocation:)forControlEvents:UIControlEventTouchDown];
    self.searchInCurrentLocation.backgroundColor = [ColorDefinition blueColor];
    [self.searchInArea addTarget:self action:@selector(searchInArea:)forControlEvents:UIControlEventTouchDown];
    self.searchInArea.backgroundColor = [ColorDefinition greenColor];
    [self.storeSearch becomeFirstResponder];
    //do not do search in current location for now
    //[self searchInCurrentLocation:nil];
    self.geocoder = [[CLGeocoder alloc] init];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.mapView addGestureRecognizer:singleFingerTap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [self hideLocationList];
    self.locationList.tag = LOCATION_LIST_TABLE_VIEW;
    [self.locationList setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75]];
    [self.locationList setSeparatorInset:UIEdgeInsetsZero];
    self.locationList.tableFooterView = [[UIView alloc] init];
    [self.locationList registerClass:[UITableViewCell class] forCellReuseIdentifier:LOCATION_LIST_CELL_REUSE_ID];
    
    self.stores = [[NSMutableArray alloc] init];
    self.storeList = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.locationBackground.frame.origin.y, self.view.frame.size.width, self.searchInArea.frame.origin.y - self.locationBackground.frame.origin.y)];
    self.storeList.tag = STORE_LIST_TABLE_VIEW;
    [self.storeList setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75]];
    self.storeList.dataSource = self;
    self.storeList.delegate = self;
    self.storeList.hidden = true;
    [self.storeList setSeparatorInset:UIEdgeInsetsZero];
    self.storeList.tableFooterView = [[UIView alloc] init];
    [self.storeList registerClass:[UserTableViewCell class] forCellReuseIdentifier:STORE_LIST_CELL_REUSE_ID];
    [self.view insertSubview:self.storeList belowSubview:self.locationBackground];
    
    [self enableSearchButton:self.storeSearch];
    [self enableSearchButton:self.locationSearch];
    
    self.filterIcon = [[UIButton alloc] initWithFrame:CGRectMake(ICON_PADDING, self.storeSearch.center.y - ICON_HEIGHT/2.0, ICON_HEIGHT, ICON_HEIGHT)];
    [self.view addSubview:self.filterIcon];
    self.filterIcon.hidden = true;
    [self.filterIcon setAlpha:0.75];
    [self.filterIcon addTarget:self action:@selector(filterIconClicked:)forControlEvents:UIControlEventTouchDown];
    self.isFilterOn = true;
    [self filterIconClicked:self];
    
    self.listIcon = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - ICON_PADDING - ICON_HEIGHT, self.storeSearch.center.y - ICON_HEIGHT/2.0, ICON_HEIGHT, ICON_HEIGHT)];
    [self.view addSubview:self.listIcon];
    self.listIcon.hidden = true;
    [self.listIcon setAlpha:0.75];
    [self.listIcon addTarget:self action:@selector(listIconClicked:)forControlEvents:UIControlEventTouchDown];
    self.isListViewOn = true;
    [self listIconClicked:self];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.tag == STORE_LIST_TABLE_VIEW) {
        [self handleSingleTap:nil];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.locationSearch endEditing:YES];
    [self.storeSearch endEditing:YES];
    [self hideLocationSearchBar];
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

- (void)hideLocationSearchBar
{
    double storeSearchTargetLength = self.view.frame.size.width - 2 * (ICON_HEIGHT);
    if (!self.locationBackground.hidden) {
        self.filterIcon.hidden = false;
        self.listIcon.hidden = false;
        [UIView animateWithDuration:0.5 animations:^{
            [self.locationSearch setCenter:CGPointMake(self.locationSearch.center.x, self.locationSearch.center.y - self.locationBackground.frame.size.height)];
            [self.locationSearch setAlpha:0.0];
            [self.locationBackground setCenter:CGPointMake(self.locationBackground.center.x, self.locationBackground.center.y - self.locationBackground.frame.size.height)];
            [self.locationBackground setAlpha:0.0];
            [self.storeList setFrame:CGRectMake(0.0, self.locationBackground.frame.origin.y + self.locationBackground.frame.size.height, self.view.frame.size.width, self.searchInArea.frame.origin.y - self.locationBackground.frame.origin.y - self.locationBackground.frame.size.height)];
            [self.storeSearch setFrame:CGRectMake(self.storeSearch.center.x - storeSearchTargetLength/2.0, self.storeSearch.frame.origin.y, storeSearchTargetLength, self.storeSearch.frame.size.height)];
        } completion:^(BOOL finished) {
            self.locationBackground.hidden = YES;
            self.locationSearch.hidden = YES;
            [self hideLocationList];
            
        }];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (searchBar.tag == STORE_SEARCH) {
        if (self.locationBackground.hidden) {
            self.locationSearch.hidden = NO;
            self.locationBackground.hidden = NO;
            self.filterIcon.hidden = true;
            self.listIcon.hidden = true;
            [UIView animateWithDuration:0.5 animations:^{
                [self.locationSearch setAlpha:1.0];
                [self.locationSearch setCenter:CGPointMake(self.locationSearch.center.x, self.locationSearch.center.y + self.locationBackground.frame.size.height)];
                [self.locationBackground setAlpha:0.75];
                [self.locationBackground setCenter:CGPointMake(self.locationBackground.center.x, self.locationBackground.center.y + self.locationBackground.frame.size.height)];
                [self.storeSearch setFrame:CGRectMake(0.0, self.storeSearch.frame.origin.y, self.locationSearch.frame.size.width, self.storeSearch.frame.size.height)];
                [self.storeList setFrame:CGRectMake(0.0, self.locationBackground.frame.origin.y + self.locationBackground.frame.size.height, self.view.frame.size.width, self.searchInArea.frame.origin.y - self.locationBackground.frame.origin.y - self.locationBackground.frame.size.height)];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
    [self hideLocationSearchBar];
    if ([self.locationSearch.text isEqualToString: @""]) {
        [self searchInArea:nil];
    } else {
        [self.geocoder geocodeAddressString:self.locationSearch.text
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
                         [self hideLocationList];
                         if (placemarks && placemarks.count > 0) {
                             for (CLPlacemark *placeMark in placemarks) {
                                 NSString *address = @"";
                                 for (NSString *subAddress in [placeMark.addressDictionary objectForKey:@"FormattedAddressLines"]){
                                     address = [address stringByAppendingString:subAddress];
                                     address = [address stringByAppendingString:@", "];
                                 }
                                 [self.locations addObject:[address substringToIndex:address.length - 2]];
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
    [self.locationList setFrame:CGRectMake(self.locationList.frame.origin.x, self.locationList.frame.origin.y, self.locationList.frame.size.width, kbPosition.y - self.locationList.frame.origin.y)];
}

- (void) showSuggestionList: (NSInteger) target {
    self.locationList.hidden = NO;
    self.locationList.tag = target;
    [self.locationList reloadData];
}

- (void) hideLocationList {
    self.locationList.hidden = YES;
    [self.locations removeAllObjects];
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
    [self.locationSearch setText:@""];
    [self updateRegionAndStores:self.curLocation.coordinate];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.curLocation != nil &&
        self.curLocation.coordinate.latitude > self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta &&
        self.curLocation.coordinate.latitude < self.mapView.region.center.latitude + self.mapView.region.span.latitudeDelta &&
        self.curLocation.coordinate.longitude > self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta &&
        self.curLocation.coordinate.longitude < self.mapView.region.center.longitude + self.mapView.region.span.longitudeDelta) {
        [self.locationSearch setImage:[UIImage imageNamed: @"current_location.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    } else {
        [self.locationSearch setImage:[UIImage imageNamed: @"current_location_gray.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }
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
    [self.stores removeAllObjects];
    NSString * feedUrl = [NSString stringWithFormat:@"user/queryUsersWithCoordinates/%f/%f/%f/%@", region.center.latitude, region.center.longitude, fmax(region.span.latitudeDelta, region.span.longitudeDelta), self.storeSearch.text];
    [[RKObjectManager sharedManager] getObjectsAtPath:feedUrl parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            [self.mapView removeAnnotation:annotation];
        }
        for (User * user in mappingResult.array) {
            [self.mapView addAnnotation:user];
            [self.stores addObject:user];
        }
        [self.storeList reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == LOCATION_LIST_TABLE_VIEW) {
        return self.locations.count;
    } else {
        return self.stores.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == LOCATION_LIST_TABLE_VIEW) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LOCATION_LIST_CELL_REUSE_ID forIndexPath:indexPath];
        if (cell) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            NSString *suggestion = [self.locations objectAtIndex:indexPath.row];
            [cell.textLabel setFont:[UIFont systemFontOfSize:12.0]];
            [cell.textLabel setText:suggestion];
        }
        return cell;
    } else {
        UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STORE_LIST_CELL_REUSE_ID forIndexPath:indexPath];
        if (cell) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            User *store = [self.stores objectAtIndex:indexPath.row];
            [cell decorateCellWithUser:store];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == LOCATION_LIST_TABLE_VIEW) {
        NSString *suggestion = [self.locations objectAtIndex:indexPath.row];
        if (self.locationList.tag == LOCATION_SEARCH) {
            [self.locationSearch setText:suggestion];
        }
        [self hideLocationList];
    } else {
        User * store = [self.stores objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"showUser" sender:store.id];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == LOCATION_LIST_TABLE_VIEW) {
        return LOCATION_LIST_HEIGHT;
    } else {
        return USER_TABLE_VIEW_CELL_HEIGHT;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUser"]) {
        [ [segue destinationViewController] setUser_id:sender];
    }
}

- (void)filterIconClicked:(id) sender {
    if (self.isFilterOn) {
        [self.filterIcon setBackgroundImage:[UIImage imageNamed:@"filter.png" ] forState:UIControlStateNormal];
        self.isFilterOn = false;
    } else {
        [self.filterIcon setBackgroundImage:[UIImage imageNamed:@"filter_on.png" ] forState:UIControlStateNormal];
        self.isFilterOn = true;
    }
}

- (void)listIconClicked:(id) sender {
    if (self.isListViewOn) {
        [self.listIcon setBackgroundImage:[UIImage imageNamed:@"list.png" ] forState:UIControlStateNormal];
        self.isListViewOn = false;
        if (!self.storeList.hidden) {
            [UIView animateWithDuration:0.5 animations:^{
                [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y - STORE_LIST_ANIMATION_VERTICAL_DELTA)];
                [self.storeList setAlpha:0.0];
            } completion:^(BOOL finished) {
                self.storeList.hidden = true;
                [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y + STORE_LIST_ANIMATION_VERTICAL_DELTA)];
            }];
        }
    } else {
        [self.listIcon setBackgroundImage:[UIImage imageNamed:@"list_on.png" ] forState:UIControlStateNormal];
        self.isListViewOn = true;
        if (self.storeList.hidden) {
            self.storeList.hidden = false;
            [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y - STORE_LIST_ANIMATION_VERTICAL_DELTA)];
            [UIView animateWithDuration:0.5 animations:^{
                [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y + STORE_LIST_ANIMATION_VERTICAL_DELTA)];
                [self.storeList setAlpha:1.0];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

@end
