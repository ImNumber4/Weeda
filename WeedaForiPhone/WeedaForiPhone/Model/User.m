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
@synthesize description;
@synthesize phone;
@synthesize street;
@synthesize city;
@synthesize state;
@synthesize country;
@synthesize zip;
@synthesize storename;
@synthesize weedCount;
@synthesize relationshipWithCurrentUser;
@synthesize weeds;
@synthesize hasAvatar;
@synthesize latitude;
@synthesize longitude;
@synthesize userType;

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
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey :[NSString stringWithFormat:@"%@, %@, %@, %@", self.street, self.city, self.state, self.zip]};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.storename;
    
    return mapItem;
}


@end
