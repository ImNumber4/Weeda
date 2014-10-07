//
//  ConversationViewController.h
//  WeedaForiPhone
//
//  Created by LV on 9/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"

@interface ConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSNumber * participant_id;
@property (nonatomic, strong) NSString * participant_username;

@end