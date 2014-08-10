//
//  UserInfoEditableCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserInfoEditableCell.h"

@implementation UserInfoEditableCell

static inline BOOL isEmpty(id thing) {
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

- (void)awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"UserInfoEditableCell" owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
    self.contentTextField.delegate = self;
    self.contentTextView.delegate = self;
    self.contentTextView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.delegate finishModifying:self.contentTextView.text sender:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (isEmpty(self.contentTextField.text)) {
        self.contentTextField.text = self.contentTextField.placeholder;
    }
    [self.delegate finishModifying:self.contentTextField.text sender:self];
}

@end
