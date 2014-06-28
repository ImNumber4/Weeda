//
//  WLAddWeedPhotoImageView.h
//  WeedaForiPhone
//
//  Created by Wu Tony on 6/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeedAddingImageView;
@protocol WeedAddingImageViewDelegate <NSObject>
@required
- (void)pressDelete:(WeedAddingImageView *)view;
@end

@interface WeedAddingImageView : UIImageView
@property (nonatomic, weak) id<WeedAddingImageViewDelegate> delegate;
@end
