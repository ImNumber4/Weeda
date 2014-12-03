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

+ (NSString *)validateUsername:(NSString *)username
{
    if (!username) {
        return @"Username can not be empty.";
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([username isEqualToString:appDelegate.currentUser.username]) {
        return @"New username should be non-empty and different from previous username.";
    }
    NSString *regex = @"[A-Za-z0-9]{1,16}";
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([usernameTest evaluateWithObject:username]) {
        return nil;
    } else {
        return @"Username should have 6-16 characters, and only numbers and letters are allowed.";
    }
}

+ (NSString *)validatePassword:(NSString *)password
{
    if (!password) {
        return @"Password can not be empty.";
    }
    NSString *pwRegStr = @"((?=.*\\d)(?=.*[A-Z])(?=.*[a-z]).{6,16})";
    NSPredicate *pwTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pwRegStr];
    if ([pwTest evaluateWithObject:password]) {
        return nil;
    } else {
        return @"Password should have 1-16 characters, including at least 1 uppercase and 1 lowercase and 1 digit.";
    }
}

+ (BOOL)isEmailValid:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
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

- (NSString *) getSimpleFormatedAddress {
    if (self.address_city) {
        return [NSString stringWithFormat:@"%@", self.address_city];
    } else {
        return nil;
    }
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
