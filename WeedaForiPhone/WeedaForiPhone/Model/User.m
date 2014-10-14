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

- (NSString *) getFormatedAddress {
    return [User _getFormatedAddress:self.address_street city:self.address_city state:self.address_state zip:self.address_zip country:self.address_country];
}

+ (NSString *) _getFormatedAddress:(NSString *) street city:(NSString*) city state:(NSString *) state zip:(NSString *) zip country:(NSString *)country {
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", street, city, state, zip, country];
}

// please make sure this method is in sync with update address
+ (NSString *) getFormatedAddressWithPlaceMark:(CLPlacemark *)placeMark {
    return [User _getFormatedAddress:[NSString stringWithFormat:@"%@ %@", placeMark.subThoroughfare, placeMark.thoroughfare] city:placeMark.locality state:placeMark.administrativeArea zip:placeMark.postalCode country:placeMark.country];
}

- (void) updateAddress:(CLPlacemark *)placeMark
{
    self.address_street = [NSString stringWithFormat:@"%@ %@", placeMark.subThoroughfare, placeMark.thoroughfare];
    self.address_city = placeMark.locality;
    self.address_state = placeMark.administrativeArea;
    self.address_country = placeMark.country;
    self.address_zip = placeMark.postalCode;
}

@end
