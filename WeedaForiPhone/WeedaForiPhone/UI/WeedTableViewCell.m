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
#import "AddWeedViewController.h"
#import "UIViewHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WeedControlView.h"

@interface WeedTableViewCell() <UITextViewDelegate, WLImageCollectionViewDelegate> {
    CGPoint _beginOffset;
    NSIndexPath *_currentIndexPath;
}

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) WeedControlView *controlView;
@property (nonatomic, retain) NSMutableDictionary *urlDictionary;

@end

@implementation WeedTableViewCell

static double PADDING = 10;
static double AVATAR_SIZE = 40;
static double TIME_LABEL_WIDTH = 70;
static double CONTROL_VIEW_HEIGHT = 25;
static double CONTENT_TEXT_FONT = 12;
static double STORE_TYPE_ICON_SIZE = 15;

- (void) awakeFromNib
{
    [self setup];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.userAvatar = [[WLImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.userInteractionEnabled = true;
    self.userAvatar.clipsToBounds = YES;
    
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
    
    self.userAvatar.userInteractionEnabled = YES;
    [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapped)]];
    [self addSubview:self.userAvatar];
    
    self.storeTypeIcon = [[UserIcon alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width - STORE_TYPE_ICON_SIZE/2.0, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height - STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE, STORE_TYPE_ICON_SIZE)];
    [self addSubview:self.storeTypeIcon];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING, PADDING, 50, self.userAvatar.frame.size.height/2.0)];
    self.usernameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.usernameLabel setTextColor:[UIColor blackColor]];
    [self.usernameLabel setFont:[UIFont boldSystemFontOfSize:CONTENT_TEXT_FONT]];
    self.usernameLabel.userInteractionEnabled = true;
    [self.usernameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapped)]];
    [self addSubview:self.usernameLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - TIME_LABEL_WIDTH, PADDING, TIME_LABEL_WIDTH, AVATAR_SIZE/2.0)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.timeLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [self.timeLabel setTextColor:[UIColor grayColor]];
    [self addSubview:self.timeLabel];
    
    self.weedContentLabel = [[UITextView alloc] initWithFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height, self.frame.size.width - PADDING - self.usernameLabel.frame.origin.x, self.userAvatar.frame.size.height/2.0)];
    [self.weedContentLabel setFont:[UIFont systemFontOfSize:CONTENT_TEXT_FONT]];
    self.weedContentLabel.delegate = self;
    self.weedContentLabel.scrollEnabled = false;
    self.weedContentLabel.userInteractionEnabled = true;
    self.weedContentLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    self.weedContentLabel.editable = false;
    self.weedContentLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [self addSubview:self.weedContentLabel];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _urlDictionary = [NSMutableDictionary new];

    
    [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];
    self.userAvatar.userInteractionEnabled = YES;
    
    self.usernameLabel.userInteractionEnabled = YES;
    [self.usernameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];
    
    if (_weedTmp) {
        _weedTmp = nil;
    }
    
    _collectionView = [self createImageCollectionView:CGRectMake(0, 0, self.frame.size.width, MASTERVIEW_IMAGEVIEW_HEIGHT)];
    _collectionView.hidden = YES;
    [self addSubview:_collectionView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedContentView:)];
    [self.weedContentLabel addGestureRecognizer:tap];
    
    _controlView = [[WeedControlView alloc] initWithFrame:CGRectMake(0, 0, 200, CONTROL_VIEW_HEIGHT) isSimpleMode:true];
    [self addSubview:_controlView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)decorateCellWithWeed:(Weed *)weed parentViewController:(UIViewController *)parentViewController
{
    _collectionView.hidden = YES;
    _dataSource = nil;
    [_urlDictionary removeAllObjects];
    _weedTmp = weed;
    _parentViewController = parentViewController;
    
    NSString *content = [self shortenURLInContent:weed.content];
    self.weedContentLabel.attributedText = [[NSAttributedString alloc]initWithString:content attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];

    CGSize textLableSize = [self.weedContentLabel sizeThatFits:CGSizeMake(self.frame.size.width - PADDING * 3 - AVATAR_SIZE, AVATAR_SIZE/2.0)];
    [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, MAX(AVATAR_SIZE/2.0, textLableSize.height))];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", weed.username];
    [self.usernameLabel setText:nameLabel];
    double maxWidth = self.frame.size.width - PADDING * 4 - AVATAR_SIZE - TIME_LABEL_WIDTH;
    CGSize size = [self.usernameLabel sizeThatFits:CGSizeMake(maxWidth, AVATAR_SIZE/2.0)];
    [self.usernameLabel setFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y, MIN(size.width, maxWidth), AVATAR_SIZE/2.0)];
    
    self.timeLabel.text = [UIViewHelper formatTime:weed.time];
    
    [self.userAvatar setImageURL:[WeedImageController imageURLOfAvatar:weed.user_id] isAvatar:YES];
    self.userAvatar.allowFullScreenDisplay = NO;
    
    [self.storeTypeIcon setUserType:weed.user_type];
    
    if (weed.images.count > 0) {
        [_collectionView setFrame:CGRectMake(0, self.weedContentLabel.frame.origin.y + self.weedContentLabel.frame.size.height, self.frame.size.width, MASTERVIEW_IMAGEVIEW_HEIGHT)];
        _dataSource = [self adjustWeedImages];
        _collectionView.hidden = NO;
        [_collectionView reloadData];
    }
    [_controlView setFrame:CGRectMake(self.frame.size.width - _controlView.frame.size.width, self.frame.size.height - CONTROL_VIEW_HEIGHT, _controlView.frame.size.width, CONTROL_VIEW_HEIGHT)];
    [_controlView decorateWithWeed:weed parentViewController:parentViewController];
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
    WLImageCollectionViewCell *cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.imageView.isLoadingSuccessed) {
        return;
    }
    
    WLImageCollectionView *imageCollectionView = [[WLImageCollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageCollectionView.dataSource = _dataSource;
    imageCollectionView.delegate = self;
    [[UIApplication sharedApplication].windows.lastObject addSubview:imageCollectionView];
    
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

+ (CGFloat)heightOfWeedTableViewCell:(Weed *)weed width:(double)width
{
    double widthForContent = width - PADDING * 3 - AVATAR_SIZE;
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, widthForContent, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:CONTROL_VIEW_HEIGHT];
    temp.attributedText = [[NSAttributedString alloc]initWithString:weed.content];
    CGSize textLableSize = [temp sizeThatFits:CGSizeMake(widthForContent, AVATAR_SIZE/2.0)];
    
    //Add the height of the other UI elements inside your cell
    CGFloat height = PADDING + AVATAR_SIZE/2.0 + textLableSize.height;
    
    if (weed.images.count > 0) {
        height = height + MASTERVIEW_IMAGEVIEW_HEIGHT + PADDING; //For Image View
    }
    return height + CONTROL_VIEW_HEIGHT;
}

- (void)handleAvatarTapped
{
    if ([self.delegate respondsToSelector:@selector(showUserViewController:)]) {
        [self.delegate showUserViewController:self];
    }
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
