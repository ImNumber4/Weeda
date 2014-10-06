//
//  Image.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-25.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeedImage : NSManagedObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber *isBig;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;

@end
