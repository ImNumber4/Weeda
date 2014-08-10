//
//  User.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/6/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "User.h"
#import "Weed.h"
#import <AddressBook/AddressBook.h>


@implementation User

@synthesize id;
@synthesize time;
@synthesize shouldBeDeleted;
@synthesize email;
@synthesize password;
@synthesize followerCount;
@synthesize followingCount;
@synthesize username;
@synthesize userDescription;
@synthesize phone;
@synthesize address_street;
@synthesize address_city;
@synthesize address_state;
@synthesize address_country;
@synthesize address_zip;
@synthesize storename;
@synthesize weedCount;
@synthesize relationshipWithCurrentUser;
@synthesize weeds;
@synthesize has_avatar;
@synthesize latitude;
@synthesize longitude;
@synthesize user_type;

- (NSString *)title {
    return self.username;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude.doubleValue;
    coordinate.longitude = self.longitude.doubleValue;
    return coordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey :[NSString stringWithFormat:@"%@, %@, %@, %@", self.address_street, self.address_city, self.address_state, self.address_zip]};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.storename;
    
    return mapItem;
}


@end
