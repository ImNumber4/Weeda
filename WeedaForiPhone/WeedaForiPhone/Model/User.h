//
//  User.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/23/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"


@interface User : RemoteObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *weeds;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addWeedsObject:(NSManagedObject *)value;
- (void)removeWeedsObject:(NSManagedObject *)value;
- (void)addWeeds:(NSSet *)values;
- (void)removeWeeds:(NSSet *)values;

@end
