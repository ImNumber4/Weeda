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
#import "BlurView.h"
#import "UIViewHelper.h"

@interface DiscoverViewController () <UITableViewDelegate, UITableViewDataSource, VendorMKAnnotationViewDelegate>

@property (nonatomic, strong) CLLocation *curLocation;
@property (nonatomic, strong) UITableView * storeList;
@property (nonatomic, strong) UIButton *filterIcon;
@property (nonatomic, strong) UIButton *listIcon;

@property (nonatomic, strong) BlurView *storeListBlurView;
@property (strong) CLLocationManager *locationManager;
@property (strong) CLGeocoder *geocoder;
@property (strong) NSMutableArray *locations;
@property (strong) NSMutableArray *stores;
@property (strong) NSMutableArray *filteredStores;

@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIButton *filterDispensary;
@property (nonatomic, strong) UIButton *filterHydro;
@property (nonatomic, strong) UIButton *filterI502;

/*
 * stores user types filter values, if it is empty, means no filter
 */
@property (nonatomic, strong) NSMutableSet *userTypeFilters;
/*
 * stores UI tag value to user types mapping
 */
@property (nonatomic, strong) NSDictionary *tagValueToUserTypeMapping;
/*
 * stores user types to tag mapping
 */
@property (nonatomic, strong) NSDictionary *userTypeToTagValueMapping;
/*
 * stores user types to color mapping
 */
@property (nonatomic, strong) NSDictionary *userTypeToColorMapping;

@end

@implementation DiscoverViewController

static const NSInteger STORE_SEARCH = 0;
static const NSInteger LOCATION_SEARCH = 1;

static const double REGION_SPAN = 2.0;
static const double ICON_HEIGHT = 28.0;
static const double COMPONENT_PADDING = 5.0;

static const NSInteger LOCATION_LIST_TABLE_VIEW = 1;
static const NSInteger STORE_LIST_TABLE_VIEW = 2;

static const double LOCATION_LIST_HEIGHT = 35;

static NSString * LOCATION_LIST_CELL_REUSE_ID = @"LocationCell";
static NSString * STORE_LIST_CELL_REUSE_ID = @"StoreCell";

static const double STORE_LIST_ANIMATION_VERTICAL_DELTA = 100;

static const double ALPHA_VALUE = 0.8;

static const double FILTER_TAB_HEIGHT = 150;

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
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, statusBarSize.width, statusBarSize.height)];
    [statusBarBackground setBackgroundColor:[ColorDefinition greenColor]];
    [self.view addSubview:statusBarBackground];
//    [self.searchBackground setBackgroundColor:[ColorDefinition greenColor]];
//    [self.locationBackground setBackgroundColor:[ColorDefinition greenColor]];
    [self.searchBackground setAlpha:ALPHA_VALUE];
    [self.locationBackground setAlpha:ALPHA_VALUE];

    self.locations = [[NSMutableArray alloc] init];
    [self.storeSearch setImage:[UIImage imageNamed: @"search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchInCurrentLocation addTarget:self action:@selector(searchInCurrentLocation:)forControlEvents:UIControlEventTouchDown];
    self.searchInCurrentLocation.backgroundColor = [ColorDefinition blueColor];
    [self.searchInArea addTarget:self action:@selector(searchInArea:)forControlEvents:UIControlEventTouchDown];
    self.searchInArea.backgroundColor = [ColorDefinition greenColor];
    [self.storeSearch becomeFirstResponder];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.mapView addGestureRecognizer:singleFingerTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [self hideLocationList];
    
    self.locationList.tag = LOCATION_LIST_TABLE_VIEW;
    [self.locationList setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:ALPHA_VALUE]];
    [self.locationList setSeparatorInset:UIEdgeInsetsZero];
    self.locationList.tableFooterView = [[UIView alloc] init];
    [self.locationList registerClass:[UITableViewCell class] forCellReuseIdentifier:LOCATION_LIST_CELL_REUSE_ID];
    
    self.stores = [[NSMutableArray alloc] init];
    self.filteredStores = [[NSMutableArray alloc] init];
    self.storeList = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.locationBackground.frame.origin.y, self.view.frame.size.width, self.searchInArea.frame.origin.y - self.locationBackground.frame.origin.y)];
    self.storeList.tag = STORE_LIST_TABLE_VIEW;
    [self.storeList setBackgroundColor:[UIColor clearColor]];
    self.storeList.dataSource = self;
    self.storeList.delegate = self;
    [self.storeList setAlpha:0.0];
    [self.storeList setSeparatorInset:UIEdgeInsetsZero];
    self.storeList.tableFooterView = [[UIView alloc] init];
    [self.storeList registerClass:[UserTableViewCell class] forCellReuseIdentifier:STORE_LIST_CELL_REUSE_ID];
    [self.view insertSubview:self.storeList belowSubview:self.locationBackground];
    self.storeList.hidden = true;
    
    [self enableSearchButton:self.storeSearch];
    [self enableSearchButton:self.locationSearch];
    
    self.filterIcon = [[UIButton alloc] initWithFrame:CGRectMake(COMPONENT_PADDING, self.storeSearch.center.y - ICON_HEIGHT/2.0, ICON_HEIGHT, ICON_HEIGHT)];
    [self.view addSubview:self.filterIcon];
    self.filterIcon.hidden = true;
    [self.filterIcon setAlpha:ALPHA_VALUE];
    [self.filterIcon addTarget:self action:@selector(filterIconClicked:)forControlEvents:UIControlEventTouchDown];
    [self turnOffFilterIcon];
    
    self.listIcon = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - COMPONENT_PADDING - ICON_HEIGHT, self.storeSearch.center.y - ICON_HEIGHT/2.0, ICON_HEIGHT, ICON_HEIGHT)];
    [self.view addSubview:self.listIcon];
    self.listIcon.hidden = true;
    [self.listIcon setAlpha:ALPHA_VALUE];
    [self.listIcon addTarget:self action:@selector(listIconClicked:)forControlEvents:UIControlEventTouchDown];
    [self turnOffListIcon];
    
    self.storeListBlurView = [[BlurView alloc] initWithFrame:self.mapView.frame];
       
    [self initFilterTab];
}

- (void) initFilterTab
{
    self.userTypeFilters = [[NSMutableSet alloc] init];
    self.tagValueToUserTypeMapping = @{
                                       [NSNumber numberWithInt:1] : USER_TYPE_DISPENSARY,
                                       [NSNumber numberWithInt:2] : USER_TYPE_HYDRO,
                                       [NSNumber numberWithInt:3] : USER_TYPE_I502
                                       };
    self.userTypeToTagValueMapping = @{
                                       USER_TYPE_DISPENSARY : [NSNumber numberWithInt:1],
                                       USER_TYPE_HYDRO : [NSNumber numberWithInt:2],
                                       USER_TYPE_I502 : [NSNumber numberWithInt:3]
                                       };
    self.userTypeToColorMapping = @{
                                    USER_TYPE_DISPENSARY : [ColorDefinition orangeColor],
                                    USER_TYPE_HYDRO : [ColorDefinition blueColor],
                                    USER_TYPE_I502 : [ColorDefinition greenColor]
                                    };
    
    self.filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.searchInArea.frame.origin.y - FILTER_TAB_HEIGHT, self.view.frame.size.width, FILTER_TAB_HEIGHT)];
    [self.filterView setBackgroundColor:[UIColor whiteColor]];
    [self.view insertSubview:self.filterView belowSubview:self.searchInArea];
    [self.filterView setAlpha:0.0];
    [self.filterView setHidden:true];
    [UIViewHelper roundCorners:self.filterView byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    UILabel *filterViewArrow= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.filterView.frame.size.width, 20.0)];
    filterViewArrow.text = @"Tap to hide";
    [filterViewArrow setTextAlignment:NSTextAlignmentCenter];
    [filterViewArrow setTextColor:[UIColor whiteColor]];
    [filterViewArrow setFont:[UIFont systemFontOfSize:12]];
    [filterViewArrow setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [self.filterView addSubview:filterViewArrow];
    UITapGestureRecognizer *singleFingerTapOnFilterViewArrow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterIconClicked:)];
    [self.filterView addGestureRecognizer:singleFingerTapOnFilterViewArrow];
    
    UILabel *filterViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, filterViewArrow.frame.size.height + COMPONENT_PADDING, self.filterView.frame.size.width, 30.0)];
    filterViewTitle.text = @"What filters you want to apply to your search?";
    [filterViewTitle setFont:[UIFont systemFontOfSize:14]];
    [filterViewTitle setTextAlignment:NSTextAlignmentCenter];
    [self.filterView addSubview:filterViewTitle];
    
    UILabel *filterByStoreTypeTitle = [[UILabel alloc] initWithFrame:CGRectMake(COMPONENT_PADDING * 2/*Use double padding*/, filterViewTitle.frame.origin.y + filterViewTitle.frame.size.height + 10, self.filterView.frame.size.width - COMPONENT_PADDING * 4.0, 30.0)];
    filterByStoreTypeTitle.text = @"Store type";
    [filterByStoreTypeTitle setFont:[UIFont systemFontOfSize:12]];
    filterByStoreTypeTitle.textColor = [UIColor darkGrayColor];
    [filterByStoreTypeTitle setTextAlignment:NSTextAlignmentLeft];
    [self.filterView addSubview:filterByStoreTypeTitle];
    
    double filterButtonWidth = (self.locationBackground.frame.size.width - COMPONENT_PADDING * 4)/3.0;
    double filterButtonY = filterByStoreTypeTitle.frame.origin.y + filterByStoreTypeTitle.frame.size.height + COMPONENT_PADDING;
    
    self.filterDispensary = [[UIButton alloc] initWithFrame:CGRectMake(COMPONENT_PADDING, filterButtonY, filterButtonWidth, 25)];
    [self.filterView addSubview:self.filterDispensary];
    [self decorateFilterButton:self.filterDispensary type:USER_TYPE_DISPENSARY];
    
    self.filterHydro = [[UIButton alloc] initWithFrame:CGRectMake(self.filterDispensary.frame.origin.x + filterButtonWidth + COMPONENT_PADDING, filterButtonY, filterButtonWidth, 25)];
    [self.filterView addSubview:self.filterHydro];
    [self decorateFilterButton:self.filterHydro type:USER_TYPE_HYDRO];
    
    self.filterI502 = [[UIButton alloc] initWithFrame:CGRectMake(self.filterHydro.frame.origin.x + filterButtonWidth + COMPONENT_PADDING, filterButtonY, filterButtonWidth, 25)];
    [self.filterView addSubview:self.filterI502];
    [self decorateFilterButton:self.filterI502 type:USER_TYPE_I502];
}

- (void) decorateFilterButton:(UIButton *) button type:(NSString *) type
{
    NSNumber *tagValue = [self.userTypeToTagValueMapping objectForKey:type];
    button.tag = [tagValue integerValue];
    UIColor *color = [ColorDefinition grayColor];
    [button setTitle:type forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(userTypeFilterClicked:)forControlEvents:UIControlEventTouchDown];
}

- (CLGeocoder *) getGeocoder
{
    if (self.geocoder == nil) {
        //do not do search in current location for now
        //[self searchInCurrentLocation:nil];
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return self.geocoder;
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
                [self.locationBackground setAlpha:ALPHA_VALUE];
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
    [self hideLocationList];
    if ([self.locationSearch.text isEqualToString: @""]) {
        [self searchInArea:nil];
    } else {
        [[self getGeocoder] geocodeAddressString:self.locationSearch.text
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
        [[self getGeocoder] geocodeAddressString:location
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
        [annotationView decorateWithAnnotation:annotation];
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

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (fullyRendered && !self.storeList.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.storeListBlurView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.storeListBlurView removeFromSuperview];
            [self.mapView addSubview:self.storeListBlurView];
            [UIView animateWithDuration:0.5 animations:^{
                [self.storeListBlurView setAlpha:1.0];
            } completion:^(BOOL finished) {
        
            }];
        }];
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
        for (User * user in mappingResult.array) {
            [self.stores addObject:user];
        }
        [self reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
}

- (void) reloadData
{
    [self.filteredStores removeAllObjects];
    for (User * user in self.stores) {
        if ([self.userTypeFilters count] == 0 || [self.userTypeFilters containsObject:user.user_type]) {
            [self.filteredStores addObject:user];
        }
    }
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    for (User * user in self.filteredStores) {
        [self.mapView addAnnotation:user];
    }
    [self.storeList reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == LOCATION_LIST_TABLE_VIEW) {
        return self.locations.count;
    } else {
        return self.filteredStores.count;
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
            [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
            [cell.textLabel setText:suggestion];
        }
        return cell;
    } else {
        UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STORE_LIST_CELL_REUSE_ID forIndexPath:indexPath];
        if (cell) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            User *store = [self.filteredStores objectAtIndex:indexPath.row];
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
        User * store = [self.filteredStores objectAtIndex:indexPath.row];
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
    if (!self.filterView.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.filterView setAlpha:0.0];
            [self.filterView setCenter:CGPointMake(self.filterView.center.x, self.filterView.center.y + STORE_LIST_ANIMATION_VERTICAL_DELTA)];
        } completion:^(BOOL finished) {
            self.filterView.hidden = true;
            [self.filterView setCenter:CGPointMake(self.filterView.center.x, self.filterView.center.y - STORE_LIST_ANIMATION_VERTICAL_DELTA)];
        }];
    } else {
        self.filterView.hidden = false;
        [self.filterView setCenter:CGPointMake(self.filterView.center.x, self.filterView.center.y + STORE_LIST_ANIMATION_VERTICAL_DELTA)];
        [UIView animateWithDuration:0.5 animations:^{
            [self.filterView setAlpha:1.0];
            [self.filterView setCenter:CGPointMake(self.filterView.center.x, self.filterView.center.y - STORE_LIST_ANIMATION_VERTICAL_DELTA)];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)listIconClicked:(id) sender {
    if (!self.storeList.hidden) {
        [self turnOffListIcon];
        [self.storeListBlurView removeFromSuperview];
        self.listIcon.enabled = false;
        [UIView animateWithDuration:0.5 animations:^{
            [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y - STORE_LIST_ANIMATION_VERTICAL_DELTA)];
            [self.storeList setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.storeList.hidden = true;
            [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y + STORE_LIST_ANIMATION_VERTICAL_DELTA)];
            self.listIcon.enabled = true;
        }];
    } else {
        [self turnOnListIcon];
        [self.mapView addSubview:self.storeListBlurView];
        self.listIcon.enabled = false;
        self.storeList.hidden = false;
        [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y - STORE_LIST_ANIMATION_VERTICAL_DELTA)];
        [UIView animateWithDuration:0.5 animations:^{
            [self.storeList setCenter:CGPointMake(self.storeList.center.x, self.storeList.center.y + STORE_LIST_ANIMATION_VERTICAL_DELTA)];
            [self.storeList setAlpha:1.0];
        } completion:^(BOOL finished) {
            self.listIcon.enabled = true;
        }];
    }
}

- (void)turnOffFilterIcon
{
    [self.filterIcon setBackgroundImage:[UIImage imageNamed:@"filter.png" ] forState:UIControlStateNormal];
    [self.filterIcon setBackgroundImage:[UIImage imageNamed:@"filter.png" ] forState:UIControlStateDisabled];
}

- (void)turnOnFilterIcon
{
    [self.filterIcon setBackgroundImage:[UIImage imageNamed:@"filter_on.png" ] forState:UIControlStateNormal];
    [self.filterIcon setBackgroundImage:[UIImage imageNamed:@"filter_on.png" ] forState:UIControlStateDisabled];
}

- (void)turnOffListIcon
{
    [self.listIcon setBackgroundImage:[UIImage imageNamed:@"list.png" ] forState:UIControlStateNormal];
    [self.listIcon setBackgroundImage:[UIImage imageNamed:@"list.png" ] forState:UIControlStateDisabled];
}

- (void)turnOnListIcon
{
    [self.listIcon setBackgroundImage:[UIImage imageNamed:@"list_on.png" ] forState:UIControlStateNormal];
    [self.listIcon setBackgroundImage:[UIImage imageNamed:@"list_on.png" ] forState:UIControlStateDisabled];
}

- (IBAction)userTypeFilterClicked:(id) sender
{
    UIButton *button = sender;
    NSString *userType = [self.tagValueToUserTypeMapping objectForKey:[NSNumber numberWithInteger:button.tag]];
    if ([self.userTypeFilters count] == 0 || ![self.userTypeFilters containsObject:userType]) {
        [self switchFilterForUserType:userType on:YES];
    } else {
        [self switchFilterForUserType:userType on:NO];
    }
}

- (void) switchFilterForUserType:(NSString *)userType on:(BOOL) shouldTurnOn
{
    NSNumber *tagValue = [self.userTypeToTagValueMapping objectForKey:userType];
    UIButton *button = (UIButton *)[self.filterView viewWithTag:[tagValue integerValue]];
    UIColor *color;
    if (shouldTurnOn) {
        color = [self.userTypeToColorMapping objectForKey:userType];
        [self.userTypeFilters addObject:userType];
    } else {
        color = [ColorDefinition grayColor];
        [self.userTypeFilters removeObject:userType];
    }
    [button setTitleColor:color forState:UIControlStateNormal];
    button.layer.borderColor = color.CGColor;
    [self adjustFilterOnIconStatus];
    [self reloadData];
}

- (void) adjustFilterOnIconStatus
{
    if ([self.userTypeFilters count] == 0) {
        [self turnOffFilterIcon];
    } else {
        [self turnOnFilterIcon];
    }
}

@end
