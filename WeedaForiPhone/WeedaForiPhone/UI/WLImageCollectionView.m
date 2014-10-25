//
//  WLImageCollectionView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/13/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLImageCollectionView.h"
#import "WeedImage.h"
#import "WeedImageController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface WLImageCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    UIView *_backgroundView;
    CGRect _originalImageViewFrame;
    
    CGPoint _beginOffset;
    
    UIDeviceOrientation _lastOrientation;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation WLImageCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setup
{
    _backgroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;
    [self addSubview:_backgroundView];
    
    _dataSource = [[NSArray alloc]init];
    _currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    _lastOrientation = UIDeviceOrientationPortrait;
    
    _imageView = [[WLImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    _layout = [[UICollectionViewFlowLayout alloc]init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.sectionInset = UIEdgeInsetsZero;
    _layout.minimumInteritemSpacing = 0.0f;
    _layout.itemSize = self.frame.size;

    _collectionView = [[UICollectionView alloc]initWithFrame:self.frame collectionViewLayout:_layout];
    [_collectionView registerClass:[WLImageCollectionViewCell class] forCellWithReuseIdentifier:@"weedImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.hidden = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_collectionView];
    [self bringSubviewToFront:_collectionView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath
{
    _currentIndexPath = currentIndexPath;
}

- (CGSize)imageSizeImageSize:(CGSize)imageSize orientation:(UIDeviceOrientation)orientation
{
    CGSize size = self.bounds.size;
    
    CGFloat ratio = 0.0;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        ratio = fmin(size.height / imageSize.width, size.width / imageSize.height);
    } else {
        ratio = fminf(size.height / imageSize.height, size.width / imageSize.width);
    }
    
    CGFloat width = imageSize.width * ratio;
    CGFloat heigth = imageSize.height * ratio;
    
    return CGSizeMake(width, heigth);
}

- (CGFloat)findMaxHeight
{
    if (!_dataSource || _dataSource.count == 0) {
        return 0;
    }
    
    NSArray *weedImages = [_dataSource sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WeedImage *image1 = obj1;
        WeedImage *image2 = obj2;
        
        CGSize size1 = [self imageSizeImageSize:CGSizeMake(image1.width.floatValue, image1.height.floatValue) orientation:UIDeviceOrientationPortrait];
        CGSize size2 = [self imageSizeImageSize:CGSizeMake(image2.width.floatValue, image2.height.floatValue) orientation:UIDeviceOrientationPortrait];
        
        if (size1.height > size2.height) {
            return NSOrderedAscending;
        } else if (size1.height == size2.height) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    WeedImage *maxImage = (WeedImage *)[weedImages objectAtIndex:0];
    CGSize maxSize = [self imageSizeImageSize:CGSizeMake(maxImage.width.floatValue, maxImage.height.floatValue) orientation:UIDeviceOrientationPortrait];
    return maxSize.height;
}

- (CGFloat)findMaxWidth
{
    if (!_dataSource || _dataSource.count == 0) {
        return 0;
    }
    
    NSArray *weedImages = [_dataSource sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WeedImage *image1 = obj1;
        WeedImage *image2 = obj2;
        
        CGSize size1 = [self imageSizeImageSize:CGSizeMake(image1.width.floatValue, image1.height.floatValue) orientation:UIDeviceOrientationLandscapeLeft];
        CGSize size2 = [self imageSizeImageSize:CGSizeMake(image2.width.floatValue, image2.height.floatValue) orientation:UIDeviceOrientationLandscapeLeft];
        
        if (size1.width > size2.width) {
            return NSOrderedAscending;
        } else if (size1.width == size2.width) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    WeedImage *maxImage = (WeedImage *)[weedImages objectAtIndex:0];
    CGSize maxSize = [self imageSizeImageSize:CGSizeMake(maxImage.width.floatValue, maxImage.height.floatValue) orientation:UIDeviceOrientationLandscapeLeft];
    return maxSize.width;
}

- (void)displayWithSelectedImage:(NSIndexPath *)indexPath currentCell:(WLImageCollectionViewCell *)cell
{
    //Add Rotation Gesture
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOrentation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    _currentIndexPath = indexPath;
    
    _imageView.frame = [self convertRect:cell.imageView.frame fromView:cell.imageView];
    _originalImageViewFrame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _imageView.frame.size.width, _imageView.frame.size.height);
    _imageView.image = cell.imageView.image;
    _imageView.hidden = NO;
    
    WeedImage *weedImage = [_dataSource objectAtIndex:indexPath.item];
    
    CGSize toSize = [WeedImageController sizeAspectScaleFitWithSize:CGSizeMake(weedImage.width.floatValue, weedImage.height.floatValue) frameSize:self.frame.size];
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = CGRectMake(0, (self.frame.size.height - toSize.height) * 0.5f, toSize.width, toSize.height);
        _backgroundView.alpha = 0.9;
    } completion:^(BOOL finished) {
        if (finished) {
//            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self displayCollectionViewWithCurrentIndexPath:indexPath];
        }
    }];
    
}

- (void)displayCollectionViewWithCurrentIndexPath:(NSIndexPath *)indexPath;
{
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    _collectionView.hidden = NO;
    _imageView.hidden = YES;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [self rotateCollectionView:orientation];
    }
}

#pragma UICollectionView Delegate, DataSource Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (WLImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WLImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weedImageCell" forIndexPath:indexPath];
    if (cell) {
        WeedImage *weedImage = [self.dataSource objectAtIndex:indexPath.row];
        [cell setCellType:WLImageCellTypeCustom];
        if ([self isVerticalLayout]) {
            CGSize imageSize = [WeedImageController sizeAspectScaleFitWithSize:CGSizeMake(weedImage.width.floatValue, weedImage.height.floatValue) frameSize:CGSizeMake(self.frame.size.height, self.frame.size.width)];
            cell.imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        } else {
            CGSize imageSize = [WeedImageController sizeAspectScaleFitWithSize:CGSizeMake(weedImage.width.floatValue, weedImage.height.floatValue) frameSize:self.frame.size];
            cell.imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        }
        
        NSURL *imageURLFull = [WeedImageController imageURLOfWeedId:weedImage.parent.id userId:weedImage.parent.user_id count:weedImage.imageId.longValue quality:100];
//        NSURL *imageURLFull = [WeedImageController imageURLOfImageId:weedImage.imageId quality:[NSNumber numberWithInt:100]];
        UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:imageURLFull.absoluteString];
        if (image) {
            cell.imageView.imageURL = imageURLFull;
        } else {
            cell.imageView.imageURL = [WeedImageController imageURLOfWeedId:weedImage.parent.id userId:weedImage.parent.user_id count:weedImage.imageId.longValue quality:25];
//            cell.imageView.imageURL = [WeedImageController imageURLOfImageId:weedImage.imageId quality:[NSNumber numberWithInt:100]];
            [cell.imageView setImageURL:imageURLFull animate:YES];
        }
        cell.imageView.allowFullScreenDisplay = NO;
    }
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize size = CGSizeZero;
//    if ([self isVerticalLayout]) {
//        size = CGSizeMake(self.frame.size.height, self.frame.size.width);
//    } else {
//        size = self.frame.size;
//    }
//    return size;
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _beginOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        return;
    }
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    CGPoint endOffset = scrollView.contentOffset;
    if (abs(endOffset.x - _beginOffset.x) > 50) {
        if (endOffset.x > _beginOffset.x && _currentIndexPath.item < (_dataSource.count - 1)) {
            _currentIndexPath = [NSIndexPath indexPathForItem:(_currentIndexPath.item + 1) inSection:_currentIndexPath.section];
        } else if (endOffset.x < _beginOffset.x && _currentIndexPath.item > 0) {
            _currentIndexPath = [NSIndexPath indexPathForItem:(_currentIndexPath.item - 1) inSection:_currentIndexPath.section];
        }
    }
    [collectionView scrollToItemAtIndexPath:_currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    if ([self.delegate respondsToSelector:@selector(collectionView:didDragToIndexPath:)]) {
        [self.delegate collectionView:self didDragToIndexPath:_currentIndexPath];
    }
}

#pragma gesture
- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    
    if (UIDeviceOrientationIsLandscape(_lastOrientation)) {
        [self rotateCollectionView:UIDeviceOrientationPortrait];
    }
    
    WLImageCollectionViewCell *cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_currentIndexPath];
    if(cell == nil) {
        [_collectionView layoutIfNeeded];
        cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_currentIndexPath];
    }
    if(cell == nil) {
        [_collectionView reloadData];
        [_collectionView layoutIfNeeded];
        cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_currentIndexPath];
    }
    
    _imageView.frame = [self convertRect:cell.imageView.frame fromView:cell];
    _imageView.image = cell.imageView.image;
    _imageView.hidden = NO;
    _collectionView.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(collectionview:cellRectWithIndexPath:)]) {
        CGRect rect = [self.delegate collectionview:self cellRectWithIndexPath:_currentIndexPath];
        _originalImageViewFrame = rect;
    }
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = _originalImageViewFrame;
        _backgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self removeFromSuperview];
    }];
}

- (void)handleOrentation:(NSNotification *)rotationNotification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    [self rotateCollectionView:orientation];
}

#pragma private

- (void)rotateCollectionView:(UIDeviceOrientation)orientation
{
    if (orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationFaceUp
        || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    
    int count = [self getCountWithOrientation:orientation];
    int lastCount = [self getCountWithOrientation:_lastOrientation];
    
    CGFloat angle = (count - lastCount) * M_PI_2;
    
    WLImageCollectionViewCell *cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_currentIndexPath];
    if (cell) {
        _imageView.frame = [self convertRect:cell.imageView.frame fromView:cell];
        _imageView.image = cell.imageView.image;
    }
    _imageView.hidden = NO;
    _collectionView.hidden = YES;
    
    [self switchLayoutWithOrientation:orientation];
    CGAffineTransform collectionViewCurrentTransform = _collectionView.transform;
    _collectionView.bounds = [self changeCollectionViewBoundsWithOrientation:orientation];
    _collectionView.transform = CGAffineTransformRotate(collectionViewCurrentTransform, angle);
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:_currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    
    CGAffineTransform imageViewCurrentTransform = _imageView.transform;
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.bounds = [self boundsWithImageSize:_imageView.image.size orientation:orientation];
        _imageView.transform = CGAffineTransformRotate(imageViewCurrentTransform, angle);
    } completion:^(BOOL finished) {
        _collectionView.hidden = NO;
        _imageView.hidden = YES;
    }];
    
    _lastOrientation = orientation;
    
}

- (void)switchLayoutWithOrientation:(UIDeviceOrientation)orientation
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        layout.itemSize = CGSizeMake(self.frame.size.height, self.frame.size.width);
    } else {
        layout.itemSize = self.frame.size;
    }
    [layout invalidateLayout];
}

- (CGRect)boundsWithImageSize:(CGSize)size orientation:(UIDeviceOrientation)orientation
{
    CGSize imageSize = CGSizeZero;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        imageSize = [WeedImageController sizeAspectScaleFitWithSize:CGSizeMake(size.width, size.height) frameSize:CGSizeMake(self.frame.size.height, self.frame.size.width)];
    } else {
        imageSize = [WeedImageController sizeAspectScaleFitWithSize:CGSizeMake(size.width, size.height) frameSize:self.frame.size];
    }
    return CGRectMake(0, 0, imageSize.width, imageSize.height);
}

- (int)getCountWithOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            return 1;
            break;
        case UIDeviceOrientationLandscapeRight:
            return -1;
            break;
        case UIDeviceOrientationPortrait:
            return 0;
            
        default:
            return 0;
            break;
    }
}

- (CGRect)changeCollectionViewBoundsWithOrientation:(UIDeviceOrientation)orientation
{
    if ([self isVerticalLayout]) {
        return CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);
    } else {
        return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

- (BOOL)isVerticalLayout
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation WLImageCollectionViewCell

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImageViewWithType:WlImageCellTypeAuto];
    }
    return self;
}

- (void)setCellType:(WLImageCellType)cellType
{
    _cellType = cellType;
    [self setupImageViewWithType:cellType];
}

- (void)prepareForReuse
{
    if (self.imageView) {
        [self.imageView removeFromSuperview];
    }
    self.imageView.image = nil;
    [self setupImageViewWithType:_cellType];
}

- (void)setupImageViewWithType:(WLImageCellType)cellType
{
    if (self.imageView) {
        self.imageView = nil;
    }
    
    switch (cellType) {
        case WlImageCellTypeAuto:
            self.imageView = [[WLImageView alloc]initWithFrame:CGRectInset(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), 0, 0)];
            self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.autoresizesSubviews = YES;
            break;
        case WLImageCellTypeCustom:
            self.imageView = [[WLImageView alloc]init];
            self.imageView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.5f);
        default:
            break;
    }
    
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.allowFullScreenDisplay = NO;
    [self.contentView addSubview:self.imageView];
}

@end