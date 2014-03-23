//
//  RemoteObject.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/23/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RemoteObject : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * id;

@end
