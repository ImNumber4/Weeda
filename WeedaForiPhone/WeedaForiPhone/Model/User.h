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

@class Weed;

@interface User : RemoteObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * followerCount;
@property (nonatomic, retain) NSNumber * followingCount;
@property (nonatomic, retain) NSSet *weeds;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addWeedsObject:(Weed *)value;
- (void)removeWeedsObject:(Weed *)value;
- (void)addWeeds:(NSSet *)values;
- (void)removeWeeds:(NSSet *)values;

@end
