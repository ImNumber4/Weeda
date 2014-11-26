//
//  WLCoreDataHelper.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 11/25/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLCoreDataHelper.h"

@implementation WLCoreDataHelper

+ (void)addCoreDataChangedNotificationTo:(id)obj selecter:(SEL)aSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:obj selector:aSelector name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

+ (void)removeNotificationFromObserver:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

@end
