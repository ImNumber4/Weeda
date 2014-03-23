//
//  Weed.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/23/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"

@class User;

@interface Weed : RemoteObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) User *user;

@end
