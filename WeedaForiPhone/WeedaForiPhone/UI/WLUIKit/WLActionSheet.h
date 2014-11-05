//
//  WLActionSheet.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/31/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLActionSheet;
@protocol WLActionSheetDelegate <NSObject>
@optional
- (void)actionSheet:(WLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface WLActionSheet : UIView

- (instancetype)initWithTitle:(NSString *)title
                              delegate:(id<WLActionSheetDelegate>)delegate
                cancelButtonTitle:(NSString *)cancelButtonTitle
         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)showInView: (UIView *)view;

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

@property (nonatomic, assign) id<WLActionSheetDelegate> delegate;

@end

@interface WLActionSheetButton : UIButton

@property (nonatomic) NSInteger index;

- (id)initWithTopCornersRounded;
- (id)initWithAllCornersRounded;
- (id)initWithBottomCornersRounded;

@end
