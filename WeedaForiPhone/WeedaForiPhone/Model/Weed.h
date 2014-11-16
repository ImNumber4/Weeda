//
//  Weed.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 5/4/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"


@interface Weed : RemoteObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * if_cur_user_seed_it;
@property (nonatomic, retain) NSNumber * if_cur_user_water_it;
@property (nonatomic, retain) NSNumber * light_id;
@property (nonatomic, retain) NSNumber * seed_count;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * user_type;
@property (nonatomic, retain) NSNumber * user_relationship_with_currentUser;
@property (nonatomic, retain) NSNumber * water_count;
@property (nonatomic, retain) NSNumber * if_cur_user_light_it;
@property (nonatomic, retain) NSNumber * light_count;
@property (nonatomic, retain) NSNumber * root_id;
@property (nonatomic, retain) NSNumber * image_count;
@property (nonatomic, retain) NSSet * images;
//mentions will not be stored in the model since we do not want to cache this at client side
//therefore, if you use NSFetchController to get weeds, you will have this value as nil
@property (nonatomic, retain) NSSet * mentions;
@property (nonatomic, retain) NSNumber * score;

@end
