//
//  WeedDetailTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedDetailTableViewCell.h"
#import "WeedImage.h"
#import "WeedImageController.h"
#import "WLImageCollectionView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define DEFAULT_IMAGE_DISPLAY_BOARD_WIDTH 320.0
#define DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1 250.0
#define DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2 200.0
#define DEFAULT_IMAGE_DISPLAY_BOARD_ACREAGE (DEFAULT_IMAGE_DISPLAY_BOARD_WIDTH * DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT)

typedef NS_ENUM(NSInteger, EnumImageWidthType)
{
    EnumImageWidthTypeFull = 0,
    EnumImageWidthTypeHalf,
    EnumImageWidthTypeOneThird,
    EnumImageWidthTypeMax
};

@interface WeedDetailTableViewCell() <UICollectionViewDelegate, UICollectionViewDataSource, WLImageCollectionViewDelegate>

@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) NSMutableArray *adjustedCellSize;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableDictionary *imageWidthDictionary;

@end

@implementation WeedDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self.userLabel addTarget:self action:@selector(showUserViewController:) forControlEvents:UIControlEventTouchDown];
    self.userLabel.userInteractionEnabled = YES;
    
    [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];
    self.userAvatar.userInteractionEnabled = YES;
    
    _imageWidthDictionary = [[NSMutableDictionary alloc]initWithCapacity:3];
    [_imageWidthDictionary setObject:[NSNumber numberWithFloat:300.0] forKey:[NSNumber numberWithInteger:EnumImageWidthTypeFull]];
    [_imageWidthDictionary setObject:[NSNumber numberWithFloat:149.0] forKey:[NSNumber numberWithInteger:EnumImageWidthTypeHalf]];
    [_imageWidthDictionary setObject:[NSNumber numberWithFloat:98.6] forKey:[NSNumber numberWithInteger:EnumImageWidthTypeOneThird]];
    
    _adjustedCellSize = [[NSMutableArray alloc]init];
    _dataSource = [[NSArray alloc]init];
    
    _collectionView = [self createCollectionViewWithRect:CGRectMake(0, 0, self.frame.size.width, DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1)];
    [self addSubview:_collectionView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)decorateCellWithWeed:(Weed *)weed
{
    if (weed.images.count > 0) {
        [self adjustImageSizeWithWeed:weed];
        
        [_collectionView setFrame:CGRectMake(self.frame.origin.x, self.weedContentLabel.frame.origin.y + self.weedContentLabel.frame.size.height, self.frame.size.width, weed.images.count > 2 ? DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1 : DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2)];
        [_collectionView reloadData];
    } else {
        _collectionView.hidden = YES;
    }
}

- (UICollectionView *)createCollectionViewWithRect:(CGRect)rect
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    layout.sectionInset = UIEdgeInsetsMake(0, 10.0, 0, 10.0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:rect collectionViewLayout:layout];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView registerClass:[WLImageCollectionViewCell class] forCellWithReuseIdentifier:@"weedImageCell"];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    
    return collectionView;
}

- (void)adjustImageSizeWithWeed:(Weed *)weed
{
    unsigned long count = weed.images.count;
    int row = 0;
    if (count > 0 && count < 3) {
        row = 1;
    } else if (count > 2 && count < 5) {
        row = 2;
    } else {
        row = 3;
    }
    
    CGFloat height = row > 1 ? (DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1 / row) : DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2;
    
    _dataSource = [[weed.images allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WeedImage *image1 = (WeedImage *)obj1;
        WeedImage *image2 = (WeedImage *)obj2;
        
        CGFloat ratio1 = [image1.width floatValue] / [image1.height floatValue];
        CGFloat ratio2 = [image2.width floatValue] / [image2.height floatValue];
        
        if (ratio1 >= ratio2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    NSMutableArray *widthArray = [[NSMutableArray alloc]init];
    while (row > 0) {
        long itemInOneRow = count / row;
        EnumImageWidthType type;
        switch (itemInOneRow) {
            case 1:
                type = EnumImageWidthTypeFull;
                [widthArray addObject:[_imageWidthDictionary objectForKey:[NSNumber numberWithInteger:EnumImageWidthTypeFull]]];
                break;
            case 2:
                type = EnumImageWidthTypeHalf;
                for (int j = 0 ; j < 2; j++) {
                    [widthArray addObject:[_imageWidthDictionary objectForKey:[NSNumber numberWithInteger:EnumImageWidthTypeHalf]]];
                }
                break;
            case 3:
                type = EnumImageWidthTypeOneThird;
                for (int j = 0; j < 3; j++) {
                    [widthArray addObject:[_imageWidthDictionary objectForKey:[NSNumber numberWithInteger:EnumImageWidthTypeOneThird]]];
                }
                break;
                
            default:
                break;
        }
        
        count -= itemInOneRow;
        row--;
    }
    
    for (int i = 0; i < weed.images.count; i++) {
        CGFloat width = [(NSNumber *)[widthArray objectAtIndex:i] floatValue];
        CGSize cellSize = CGSizeMake(width, height);
        [_adjustedCellSize addObject:[NSValue valueWithCGSize:cellSize]];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _adjustedCellSize.count;
}

- (WLImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WLImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weedImageCell" forIndexPath:indexPath];
    if (cell) {
        WeedImage *weedImage = [_dataSource objectAtIndex:indexPath.row];
        cell.imageView.imageURL = [WeedImageController imageURLOfWeedId:weedImage.parent.id userId:weedImage.parent.user_id count:weedImage.imageId.longValue quality:25];
        cell.imageView.allowFullScreenDisplay = NO;
    } else {
        NSLog(@"Cell not exist!");
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSValue *cellSize = [_adjustedCellSize objectAtIndex:indexPath.row];
    return CGSizeMake([cellSize CGSizeValue].width, [cellSize CGSizeValue].height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WLImageCollectionView *imageCollectionView = [[WLImageCollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageCollectionView.dataSource = _dataSource;
    imageCollectionView.delegate = self;
    [[UIApplication sharedApplication].windows.lastObject addSubview:imageCollectionView];
    
    WLImageCollectionViewCell *cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    [imageCollectionView displayWithSelectedImage:indexPath currentCell:cell];
}

- (void)handleAvatarTapped
{
    [self showUserViewController:self];
}

- (void)showUserViewController:(id)sender
{
    [self.delegate showUserViewController:sender];
}

#pragma delegate WLImageCollectionView
- (CGRect)collectionview:(WLImageCollectionView *)collectionView cellRectWithIndexPath:(NSIndexPath *)indexPath
{
    WLImageCollectionViewCell *cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    return [collectionView convertRect:cell.frame fromView:_collectionView];
}

@end
