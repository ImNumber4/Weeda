//
//  WLCoreDataHelper.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 11/25/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLCoreDataHelper : NSObject

+ (void)addCoreDataChangedNotificationTo:(id)obj selecter:(SEL)aSelector;

@end
