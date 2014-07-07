//
//  VendorMKAnnotationView.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/29/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "VendorCallOutView.h"

@interface VendorMKAnnotationView : MKAnnotationView

@property (nonatomic, retain) VendorCallOutView * calloutView;

@end
