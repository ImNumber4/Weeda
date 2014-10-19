//
//  User.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/6/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"
#import <MapKit/MapKit.h>

#define USER_TYPE_USER @"user"
#define USER_TYPE_DISPENSARY @"dispensary"
#define USER_TYPE_HYDRO @"hydro"
#define USER_TYPE_I502 @"i502"

@interface User : NSObject <MKAnnotation>
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * followerCount;
@property (nonatomic, retain) NSNumber * followingCount;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userDescription;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * storename;
@property (nonatomic, retain) NSString * address_street;
@property (nonatomic, retain) NSString * address_city;
@property (nonatomic, retain) NSString * address_state;
@property (nonatomic, retain) NSString * address_country;
@property (nonatomic, retain) NSString * address_zip;
@property (nonatomic, retain) NSNumber * weedCount;
@property (nonatomic, retain) NSNumber * relationshipWithCurrentUser;
@property (nonatomic, retain) NSSet *weeds;
@property (nonatomic, retain) NSNumber *has_avatar;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString * user_type;


- (MKMapItem*)mapItem;
- (NSString *) getFormatedAddress;
- (NSString *) getSimpleFormatedAddress;
- (void) updateAddress:(CLPlacemark *)placeMark;
+ (NSString *) getFormatedAddressWithPlaceMark:(CLPlacemark *)placeMark;

@end
