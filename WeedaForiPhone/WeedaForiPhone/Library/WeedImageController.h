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

+ (NSURL *)imageURLOfWeedId: (NSNumber *)weedId userId:(NSNumber *)userId count:(long)count;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToSize:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToWidth:(CGFloat)width;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToHeight:(CGFloat)height;

@end
