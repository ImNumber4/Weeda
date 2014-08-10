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
@end

@interface UserInfoEditableCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *contentTextField;
@property (nonatomic, weak) IBOutlet UITextView *contentTextView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UIView *view;

@property (nonatomic, weak)id<UserInfoEditableCellDelegate> delegate;

@end
