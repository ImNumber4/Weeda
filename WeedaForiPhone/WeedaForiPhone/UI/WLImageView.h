//
//  WLImageView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLImageView : UIImageView

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) NSString *imageId;
@property (nonatomic) NSInteger quality;

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) NSArray *dataSource;

@property (nonatomic) BOOL allowFullScreenDisplay;
@property (nonatomic) BOOL allowCollectionViewDisplay;

- (void)setImageURL:(NSURL *)imageURL animate:(BOOL)animate;

@end
