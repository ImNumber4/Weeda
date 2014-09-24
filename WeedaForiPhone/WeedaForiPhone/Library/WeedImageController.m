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

+ (NSURL *)imageURLOfWeedId:(NSNumber *)weedId userId:(NSNumber *)userId count:(long)count
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.cannablaze.com/image/query/weed_%@_%@_%ld", userId, weedId, count]];
}

+ (UIImage*)imageWithImage:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat ratio = width / height;
    
    CGSize newSize;
    
    if (width > height) {
        newSize = CGSizeMake(size.height * ratio, size.height);
    } else {
        newSize = CGSizeMake(size.width, size.width / ratio);
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

@end
