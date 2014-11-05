//
//  WLAddWeedToolbar.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 6/15/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeedAddingToolbar;
@protocol WeedAddingToolbarDelegate <NSObject>
@required
- (void)pressTakingPicture:(WeedAddingToolbar *)view;
- (void)pressPickingPicture:(WeedAddingToolbar *)view;
- (void)pressCopyLink:(WeedAddingToolbar *)view;
@end

@interface WeedAddingToolbar : UIView

@property (nonatomic, weak)id<WeedAddingToolbarDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *view;

- (IBAction)takePicturePress:(id)sender;
- (IBAction)pickPicturePress:(id)sender;
- (IBAction)copyLinkPress:(id)sender;

@end
