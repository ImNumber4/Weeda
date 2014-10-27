//
//  UserInfoEditableCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UserInfoEditableCellDelegate <NSObject>
@required
- (void) finishModifying:(NSString *)text sender:(UITableViewCell *) sender;
- (void) contentDidChange:(NSString *)text sender:(UITableViewCell *) sender;
@end

@interface UserInfoEditableCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextField *contentTextField;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, weak)id<UserInfoEditableCellDelegate> delegate;

- (void) adjustNameLabelWidth:(double)width;

@end
