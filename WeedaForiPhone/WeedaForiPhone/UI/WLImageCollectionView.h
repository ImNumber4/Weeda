//
//  WLImageCollectionView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/13/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeedImage.h"
#import "WLImageView.h"

@class WLImageCollectionView;
@protocol WLImageCollectionViewDelegate <NSObject>
@optional
- (void)collectionView:(WLImageCollectionView *)collectionView didDragToIndexPath:(NSIndexPath *)indexPath;
- (CGRect)collectionview:(WLImageCollectionView *)collectionView cellRectWithIndexPath:(NSIndexPath *)indexPath;
@end

@interface WLImageCollectionViewCell : UICollectionViewCell

typedef NS_ENUM(NSInteger, WLImageCellType) {
    WlImageCellTypeAuto,
    WLImageCellTypeCustom
};

@property (nonatomic, retain) WLImageView *imageView;

@property (nonatomic) WLImageCellType cellType;

@end

@interface WLImageCollectionView : UIView

@property (nonatomic, weak) id<WLImageCollectionViewDelegate> delegate;

@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;

- (void)displayWithSelectedImage:(NSIndexPath *)indexPath currentCell:(WLImageCollectionViewCell *)cell;

@end