//
//  WeedTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedTableViewCell.h"
#import "WeedImageController.h"
#import "WLImageCollectionView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define MIN_HEIGHT_OF_TEXT_VIEW 40.0
#define DEFAULT_WEED_CONTENT_LABLE_WIDTH 256.0

@interface WeedTableViewCell() <UITextViewDelegate, WLImageCollectionViewDelegate> {
    CGPoint _beginOffset;
    NSIndexPath *_currentIndexPath;
}

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSArray *dataSource;

@property (nonatomic, retain) NSMutableDictionary *urlDictionary;

@end

@implementation WeedTableViewCell

- (void)awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"WeedTableViewCell" owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
    
    _urlDictionary = [NSMutableDictionary new];
    
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    
    [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];
    self.userAvatar.userInteractionEnabled = YES;
    
    self.usernameLabel.userInteractionEnabled = YES;
    [self.usernameLabel addTarget:self action:@selector(showUserViewController:) forControlEvents:UIControlEventTouchDown];
    
    if (_weedTmp) {
        _weedTmp = nil;
    }
    
    _collectionView = [self createImageCollectionView:CGRectMake(0, 0, self.frame.size.width, MASTERVIEW_IMAGEVIEW_HEIGHT)];
    _collectionView.hidden = YES;
    [self addSubview:_collectionView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedContentView:)];
    [self.weedContentLabel addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hideControls
{
    self.light.hidden = true;
    self.lightCount.hidden = true;
    self.seed.hidden = true;
    self.seedCount.hidden = true;
    self.waterDrop.hidden = true;
    self.waterCount.hidden = true;
}

- (void)decorateCellWithWeed:(Weed *)weed
{
    _weedTmp = weed;
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    
    
    NSString *content = [self shortenURLInContent:weed.content];
    self.weedContentLabel.attributedText = [[NSAttributedString alloc]initWithString:content];
    self.weedContentLabel.translatesAutoresizingMaskIntoConstraints = YES;
    CGSize textLableSize = [self.weedContentLabel sizeThatFits:CGSizeMake(DEFAULT_WEED_CONTENT_LABLE_WIDTH, MIN_HEIGHT_OF_TEXT_VIEW)];
    [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, MAX(MIN_HEIGHT_OF_TEXT_VIEW, textLableSize.height))];
    self.weedContentLabel.delegate = self;
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", weed.username];
    [self.usernameLabel setTitle:nameLabel forState:UIControlStateNormal];
    [self.usernameLabel sizeToFit];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    
    if ([weed.if_cur_user_water_it intValue] == 1) {
        [self.waterDrop setImage:[UIImage imageNamed:@"waterdrop.png"] forState:UIControlStateNormal];
    } else {
        [self.waterDrop setImage:[UIImage imageNamed:@"waterdropgray.png"] forState:UIControlStateNormal];
    }
    if ([weed.if_cur_user_seed_it intValue] == 1) {
        [self.seed setImage:[UIImage imageNamed:@"seed.png"] forState:UIControlStateNormal];
    } else {
        [self.seed setImage:[UIImage imageNamed:@"seedgray.png"] forState:UIControlStateNormal];
    }
    if ([weed.if_cur_user_light_it intValue] == 1) {
        [self.light setImage:[UIImage imageNamed:@"light.png"] forState:UIControlStateNormal];
    } else {
        [self.light setImage:[UIImage imageNamed:@"lightgray.png"] forState:UIControlStateNormal];
    }
    self.lightCount.text = [NSString stringWithFormat:@"%@", weed.light_count];
    self.seedCount.text = [NSString stringWithFormat:@"%@", weed.seed_count];
    self.waterCount.text = [NSString stringWithFormat:@"%@", weed.water_count];
    
    [self.userAvatar setImageURL:[WeedImageController imageURLOfAvatar:weed.user_id] isAvatar:YES];
    self.userAvatar.allowFullScreenDisplay = NO;
    
    if (weed.images.count > 0) {
        [_collectionView setFrame:CGRectMake(0, self.weedContentLabel.frame.origin.y + self.weedContentLabel.frame.size.height, self.frame.size.width, MASTERVIEW_IMAGEVIEW_HEIGHT)];
        _dataSource = [self adjustWeedImages];
        _collectionView.hidden = NO;
        [_collectionView reloadData];
    }
}

- (void)prepareForReuse
{
    _weedTmp = nil;
    _collectionView.hidden = YES;
    _dataSource = nil;
}

- (NSArray *)adjustWeedImages
{
    NSArray *dataSource = [[_weedTmp.images allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WeedImage *image1 = obj1;
        WeedImage *image2 = obj2;
        
        if (image1.imageId > image2.imageId) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];

    return dataSource;
}

#pragma mark - private

- (UICollectionView *)createImageCollectionView:(CGRect)rect
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(280.0, 200.0);
    layout.minimumLineSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    layout.sectionInset = UIEdgeInsetsMake(0, (self.superview.bounds.size.width - layout.itemSize.width) / 2, 0, (self.superview.bounds.size.width - layout.itemSize.width) / 2);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:rect collectionViewLayout:layout];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView registerClass:[WLImageCollectionViewCell class] forCellWithReuseIdentifier:@"weedImageCell"];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.userInteractionEnabled = YES;
    
    _currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    return collectionView;
}

- (NSString *)shortenURLInContent:(NSString *)content
{
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc]initWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *results = [detector matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *result in results) {
        if (result.URL) {
            NSString *url = result.URL.shortenString;
            [_urlDictionary setObject:result.URL.absoluteString forKey:url];
            content = [content stringByReplacingCharactersInRange:result.range withString:url];
        }
    }
    return content;
}

#pragma mark - CollectionView & DataSource delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _weedTmp.images.count;
}

- (WLImageCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WLImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weedImageCell" forIndexPath:indexPath];
    if (cell) {
        WeedImage *weedImage = [_dataSource objectAtIndex:indexPath.row];
        cell.imageView.imageURL = [WeedImageController imageURLOfWeedId:weedImage.parent.id userId:weedImage.parent.user_id count:weedImage.imageId.longValue quality:25];
        cell.imageView.allowFullScreenDisplay = NO;
    } else {
        NSLog(@"Cell is nil.");
    }
    
    return cell;
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, (self.superview.bounds.size.width - 280) / 2, 0, (self.superview.bounds.size.width - 280) / 2);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _beginOffset = scrollView.contentOffset;
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
    [collectionView scrollToItemAtIndexPath:_currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:NO];
}

+ (CGFloat)heightOfWeedTableViewCell:(Weed *)weed
{
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_WEED_CONTENT_LABLE_WIDTH, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:11.0];
    temp.attributedText = [[NSAttributedString alloc]initWithString:weed.content];
    CGSize textLableSize = [temp sizeThatFits:CGSizeMake(DEFAULT_WEED_CONTENT_LABLE_WIDTH, MIN_HEIGHT_OF_TEXT_VIEW)];
    
    //Add the height of the other UI elements inside your cell
    if (weed.images.count > 0) {
        CGFloat height = MAX(textLableSize.height, MIN_HEIGHT_OF_TEXT_VIEW) + 20.0 + MASTERVIEW_IMAGEVIEW_HEIGHT + 30.0; //For Image View
        return height;
    } else {
        CGFloat height = MAX(textLableSize.height, MIN_HEIGHT_OF_TEXT_VIEW) + 35.0;
        return height;
    }
}

- (void)handleAvatarTapped
{
    [self showUserViewController:self];
}

- (void)showUserViewController:(id)sender
{
    [self.delegate showUserViewController:sender];
}

#pragma WLImageCollectionView Delegate
- (void)collectionView:(WLImageCollectionView *)collectionView didDragToIndexPath:(NSIndexPath *)indexPath
{
    _currentIndexPath = indexPath;
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)tappedContentView:(UIGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(selectWeedContent:)]) {
        [self.delegate selectWeedContent:recognizer];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(pressURL:)]) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http|https):\\/\\/)" options:NSRegularExpressionCaseInsensitive error:&error];
        NSString *shortenUrl = [regex stringByReplacingMatchesInString:URL.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, URL.absoluteString.length) withTemplate:@""];
        NSString *url = [_urlDictionary objectForKey:shortenUrl];
        return [self.delegate pressURL:[NSURL URLWithString:url]];
    }
    return YES;
}

@end
