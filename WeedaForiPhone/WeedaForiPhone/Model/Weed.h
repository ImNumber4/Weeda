//
//  Weed.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/13/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"

@class User;

@interface Weed : RemoteObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * water_count;
@property (nonatomic, retain) NSNumber * if_cur_user_water_it;
@property (nonatomic, retain) User *user;

@end
