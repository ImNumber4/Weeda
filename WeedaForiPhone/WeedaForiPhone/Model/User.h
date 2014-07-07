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

@interface User : NSObject <MKAnnotation>
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * followerCount;
@property (nonatomic, retain) NSNumber * followingCount;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * storename;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSNumber * weedCount;
@property (nonatomic, retain) NSNumber * relationshipWithCurrentUser;
@property (nonatomic, retain) NSSet *weeds;
@property (nonatomic, retain) NSNumber *hasAvatar;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString * userType;


- (MKMapItem*)mapItem;

@end
