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

+ (NSString *)imageRelatedURLWithWeed: (Weed *)weed count:(NSNumber *)count;

+ (NSURL *)imageURLOfWeedId:(NSNumber *)weedId userId:(NSNumber *)userId count:(long)count quality:(long)quality;

+ (NSURL *)imageURLOfImageId: (NSString *)imageId quality:(NSNumber *)quality;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToSize:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToWidth:(CGFloat)width;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToHeight:(CGFloat)height;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToRatio:(CGFloat)ratio;

+ (CGSize) translateSizeWithFrameSize:(CGSize)size frameSize:(CGSize)frameSize;

+ (CGSize)sizeAspectScaleFitWithSize:(CGSize)originalSize frameSize:(CGSize)frameSize;

@end
