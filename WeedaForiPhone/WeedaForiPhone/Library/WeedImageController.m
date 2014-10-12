//
//  WeedImageController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 7/20/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedImageController.h"

static NSString *baseUrl = @"http://www.cannablaze.com/image/query";

@implementation WeedImageController

+ (NSURL *)imageURLOfAvatar:(NSNumber *)userId
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/avatar_%@", baseUrl, userId]];
}

+ (NSURL *)imageURLOfWeed:(Weed *)weed
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/weed_%@_%@_%@", baseUrl, weed.user_id, weed.id, weed.image_count]];
}

+ (NSString *)imageRelatedURLWithWeed:(Weed *)weed count:(NSNumber *)count
{
    return [NSString stringWithFormat:@"weed_%@_%@_%@", weed.user_id, weed.id, count];
}

+ (NSURL *)imageURLOfWeedId:(NSNumber *)weedId userId:(NSNumber *)userId count:(long)count
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/weed_%@_%@_%ld", baseUrl, userId, weedId, count]];
}

+ (NSURL *)imageURLOfImageId:(NSString *)imageId quality:(NSNumber *)quality
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?quality=%@", baseUrl, imageId, quality]];
}

+ (UIImage *)imageWithImage:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat ratio = width / height;
    CGFloat frameRatio = size.width / size.height;
    
    CGSize newSize;
    
    if (size.width > size.height && frameRatio > ratio) {
        newSize = CGSizeMake(size.width, size.width / ratio);
    } else {
        newSize = CGSizeMake(size.height * ratio, size.height);
    }
    
    UIImage *newImage = nil;
    UIGraphicsBeginImageContext( newSize );
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToWidth:(CGFloat)width
{
    CGFloat originalWidth = originalImage.size.width;
    CGFloat originalHeight = originalImage.size.height;
    
    CGFloat ratio = originalWidth / originalHeight;
    
    CGSize newSize = CGSizeMake(width, width / ratio);
    
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToHeight:(CGFloat)height
{
    if (!originalImage) {
        return nil;
    }
    
    CGFloat originalWidth = originalImage.size.width;
    CGFloat originalHeight = originalImage.size.height;
    CGFloat ratio = originalWidth / originalHeight;
    
    CGSize newSize = CGSizeMake(height * ratio, height);
    
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToRatio:(CGFloat)ratio
{
    if (!originalImage) {
        return nil;
    }
    
    CGSize newSize = CGSizeMake(originalImage.size.width * ratio, originalImage.size.height * ratio);
    return [self imageWithImage:newSize originalImage:originalImage];
}

+ (UIImage *)imageWithImage:(CGSize)size originalImage:(UIImage *)originalImage
{
    UIGraphicsBeginImageContext(size);
    [originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
