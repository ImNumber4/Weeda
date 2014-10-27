//
//  UserInfoEditableCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 7/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserInfoEditableCell.h"

@implementation UserInfoEditableCell

static const double VERTICAL_PADDING = 5;
static const double HORIZONTAL_PADDING = 10;
static const double LABEL_HEIGHT = 40;
static const double FONT_SIZE = 12;

static inline BOOL isEmpty(id thing) {
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, VERTICAL_PADDING, 70, LABEL_HEIGHT)];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        [self addSubview:self.nameLabel];
        
        self.contentTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width + HORIZONTAL_PADDING, VERTICAL_PADDING, self.frame.size.width - HORIZONTAL_PADDING * 3 - self.nameLabel.frame.size.width, LABEL_HEIGHT)];
        [self.contentTextField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:self.contentTextField];
        self.contentTextField.returnKeyType = UIReturnKeyDone;
        [self.contentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.contentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.contentTextField.frame.origin.x, self.contentTextField.frame.origin.y, self.contentTextField.frame.size.width, 90)];
        [self.contentTextView setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:self.contentTextView];
        self.contentTextView.returnKeyType = UIReturnKeyDone;
        
        self.contentTextField.delegate = self;
        self.contentTextView.delegate = self;
        self.contentTextView.hidden = YES;
    }
    return self;
}

- (void) adjustNameLabelWidth:(double) width
{
    [self.nameLabel setFrame:CGRectMake(HORIZONTAL_PADDING, VERTICAL_PADDING, width, LABEL_HEIGHT)];
    [self.contentTextField setFrame:CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width + HORIZONTAL_PADDING, VERTICAL_PADDING, self.frame.size.width - HORIZONTAL_PADDING * 3 - self.nameLabel.frame.size.width, LABEL_HEIGHT)];
    [self.contentTextView setFrame:CGRectMake(self.contentTextField.frame.origin.x, self.contentTextField.frame.origin.y, self.contentTextField.frame.size.width, 90)];
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

- (void)textViewDidChange:(UITextView *)textView
{
    [self.delegate contentDidChange:self.contentTextView.text sender:self];
}

-(void)textFieldDidChange :(UITextField *)textField
{
    [self.delegate contentDidChange:self.contentTextField.text sender:self];
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
