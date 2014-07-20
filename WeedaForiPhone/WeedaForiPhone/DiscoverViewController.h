//
//  DiscoverViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/6/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *storeSearch;
@property (weak, nonatomic) IBOutlet UISearchBar *location;
@property (weak, nonatomic) IBOutlet UIButton *searchInArea;
@property (weak, nonatomic) IBOutlet UIButton *searchInCurrentLocation;
@property (weak, nonatomic) IBOutlet UIView *searchBackground;
@property (weak, nonatomic) IBOutlet UIView *locationBackground;
@property (nonatomic, retain) IBOutlet UITableView *suggestionList;
@property (strong) CLLocationManager *locationManager;
@property (strong) CLGeocoder *geocoder;
@property (strong) NSMutableArray *suggestions;

@end
