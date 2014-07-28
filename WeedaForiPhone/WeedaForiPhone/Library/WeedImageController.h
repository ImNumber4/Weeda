//
//  WeedImageController.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 7/20/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "weed.h"

@interface WeedImageController : NSObject

+ (NSURL *)imageURLOfAvatar: (NSNumber *)userId;

+ (NSURL *)imageURLOfWeed: (Weed *)weed;

@end
