//
//  ImageUtil.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageUtil : NSObject

+ (UIImage *) renderImage:(UIImage *)image atSize:(const CGSize) size;

+ (UIImage *) colorImage:(UIImage *)image color:(UIColor *)color;

@end
