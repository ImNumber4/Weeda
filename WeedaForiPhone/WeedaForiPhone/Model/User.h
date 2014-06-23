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


@interface User : NSObject

@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * followerCount;
@property (nonatomic, retain) NSNumber * followingCount;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSNumber * weedCount;
@property (nonatomic, retain) NSNumber * relationshipWithCurrentUser;
@property (nonatomic, retain) NSSet *weeds;
@property (nonatomic, retain) NSNumber *hasAvatar;

@end
