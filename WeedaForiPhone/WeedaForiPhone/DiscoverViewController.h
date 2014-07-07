//
//  DiscoverViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/6/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong) CLLocationManager *locationManager;

@end
