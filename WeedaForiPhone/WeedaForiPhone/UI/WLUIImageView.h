//
//  WLUIImageView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-5-4.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLUIImageView : UIImageView <UIGestureRecognizerDelegate>

- (void)setImageWithUser:(NSNumber *)userId;

@end
