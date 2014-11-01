//
//  UIViewHelper.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewHelper.h"

@implementation UIViewHelper

+ (void) roundCorners:(UIView *) view byRoundingCorners:(UIRectCorner)corners
{
    [UIViewHelper roundCorners:view byRoundingCorners:corners radius:10.0];
}

+ (void) roundCorners:(UIView *) view byRoundingCorners:(UIRectCorner)corners radius:(double) radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    view.layer.mask = maskLayer;
}

+ (void) insertLeftPaddingToTextField:(UITextField *) textField width:(double)width
{
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, textField.frame.size.height)];
    textField.leftViewMode = UITextFieldViewModeAlways;
}

@end