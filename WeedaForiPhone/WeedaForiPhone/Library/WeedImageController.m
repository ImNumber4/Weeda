//
//  WeedImageController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 7/20/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedImageController.h"

@implementation WeedImageController

+ (NSURL *)imageURLOfAvatar:(NSNumber *)userId
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.cannablaze.com/image/query/avatar_%@", userId]];
}

+ (NSURL *)imageURLOfWeed:(Weed *)weed
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.cannablaze.com/image/query/weed_%@_%@_%@", weed.user_id, weed.id, weed.image_count]];
}

@end
