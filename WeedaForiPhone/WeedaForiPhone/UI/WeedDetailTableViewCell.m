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
#import "YTPlayerView.h"
#import "TFHpple.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define DEFAULT_IMAGE_DISPLAY_BOARD_WIDTH 320.0
#define DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1 250.0
#define DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2 200.0
#define DEFAULT_IMAGE_DISPLAY_BOARD_ACREAGE (DEFAULT_IMAGE_DISPLAY_BOARD_WIDTH * DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT)

#define DEFAULT_VIDEO_WIDTH 300
#define DEFAULT_VIDEO_HEIGHT 168.75f

#define TEXTLABLE_WEED_CONTENT_ORIGIN_Y 59

#define WEB_SERVER_GET_FAVICON_URL @"http://www.google.com/s2/favicons?domain="

typedef NS_ENUM(NSInteger, EnumImageWidthType)
{
    EnumImageWidthTypeFull = 0,
    EnumImageWidthTypeHalf,
    EnumImageWidthTypeOneThird,
    EnumImageWidthTypeMax
};

typedef NS_ENUM(NSInteger, DetailCellShowingType)
{
    DetailCellShowingTypeDefault = 0,
    DetailCellShowingTypeImages,
    DetailCellShowingTypeVideo,
    DetailCellShowingTypeUrl
};

@interface WeedDetailTableViewCell() <UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSURLConnectionDataDelegate, WLImageCollectionViewDelegate, YTPlayerViewDelegate>

@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) NSMutableArray *adjustedCellSize;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableDictionary *imageWidthDictionary;
@property (nonatomic, retain) NSMutableDictionary *urlDictionary;

@property (nonatomic, retain) UIView *webSummaryView;
@property (nonatomic, retain) UIImageView *faviconView;
@property (nonatomic, retain) UITextView *titleView;
@property (nonatomic, retain) UITextView *descriptionView;
@property (nonatomic, retain) YTPlayerView *playerView;
@property (nonatomic, retain) NSMutableData *responseData;

@property (nonatomic, retain) NSLayoutConstraint *titleHeightConstraint;
@property (nonatomic, retain) NSLayoutConstraint *descHeightConstraint;

@property (nonatomic) DetailCellShowingType type;

@property (nonatomic, retain) NSURLConnection *connection;

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
    
    _adjustedCellSize = [NSMutableArray new];
    _urlDictionary = [NSMutableDictionary new];
    _dataSource = [[NSArray alloc]init];
    
    _collectionView = [self createCollectionViewWithRect:CGRectMake(0, 0, self.frame.size.width, DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1)];
    [self addSubview:_collectionView];
    _collectionView.hidden = YES;
    
    [self createWebSummaryView];
    
    //Add notification about quit full screen display
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:UIWindowDidBecomeHiddenNotification object:self.window];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)decorateCellWithWeed:(Weed *)weed
{
    NSString *username = weed.username;
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
    [self.userLabel setTitle:nameLabel forState:UIControlStateNormal];
    
    NSString *content = [self shortenURLInContent:weed.content];
    self.weedContentLabel.text = content;
    self.weedContentLabel.delegate = self;
    self.weedContentLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, [self getTextLableHeight:content])];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
    NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
    
    [self.userAvatar setImageURL:[WeedImageController imageURLOfAvatar:weed.user_id] isAvatar:YES];
    self.userAvatar.allowFullScreenDisplay = NO;
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];

    _type = [self getShowingTypewWithWeed:weed];
    switch (_type) {
        case DetailCellShowingTypeImages:
        {
            [self adjustImageSizeWithWeed:weed];
            [_collectionView setFrame:CGRectMake(self.frame.origin.x, self.weedContentLabel.frame.origin.y + self.weedContentLabel.frame.size.height, self.frame.size.width, weed.images.count > 2 ? DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1 : DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2)];
            [_collectionView reloadData];
            _collectionView.hidden = NO;
            break;
        }
        case DetailCellShowingTypeVideo:
        {
            NSString *videoUrl = [self stringURLFromYouTube];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:videoUrl]];
            _connection = [NSURLConnection connectionWithRequest:request delegate:self];
            break;
        }
        case DetailCellShowingTypeUrl:
        {
            NSString *url = _urlDictionary.allValues.firstObject;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            _connection = [NSURLConnection connectionWithRequest:request delegate:self];
            break;
        }
        default:
            break;
    }
    
    CGFloat height = [self heightForCell];
    if (self.delegate) {
        [self.delegate tableViewCell:self height:height needReload:NO];
    }
}

- (void)cellWillDisappear
{
    if (_playerView.playerState == kYTPlayerStatePlaying) {
        [_playerView stopVideo];
    }
    [_playerView clearVideo];
    
    [_connection cancel];
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

#pragma mark - private
- (CGFloat)heightForCell
{
    CGFloat height = 0;
    
    CGFloat textLableHeight = [self getTextLableHeight:self.weedContentLabel.text];
    switch (_type) {
        case DetailCellShowingTypeImages:
            height = self.dataSource.count < 3 ? TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 200.0 + 10 : TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 250.0 + 10;
            break;
        case DetailCellShowingTypeVideo:
        case DetailCellShowingTypeUrl:
            height = TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 10;
            break;
        default:
            height = TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + 10;
            break;
    }
    
    return height;
}

- (CGFloat)getTextLableHeight:(NSString *)text
{
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:12.0];
    temp.text = text;
    
    CGFloat textViewWidth = 200.0;
    CGRect tempFrame = CGRectMake(0, 0, textViewWidth, 40); //The height of this frame doesn't matter.
    CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.
    
    return MAX(tvsize.height, 40.0);
}

- (CGFloat)heightOfTextView:(UITextView *)textView
{
    CGFloat width = CGRectGetWidth(textView.frame);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width, 44.0f)];
    return newSize.height;
}

- (void)createWebSummaryView
{
    _webSummaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT + 20 + 10)];
    
    _faviconView = [UIImageView new];
    _faviconView.contentMode = UIViewContentModeCenter;
    
    _titleView = [UITextView new];
    [_titleView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    _titleView.editable = NO;
    _titleView.selectable = NO;
    _titleView.textColor = [UIColor darkGrayColor];
    
    _playerView = [YTPlayerView new];
    _playerView.delegate = self;
    _playerView.hidden = YES;
    
    
    _descriptionView = [UITextView new];
    _descriptionView.editable = NO;
    _descriptionView.selectable = NO;
    _descriptionView.hidden = YES;
    _descriptionView.textColor = [UIColor darkGrayColor];
    
    [_webSummaryView addSubview:_faviconView];
    [_webSummaryView addSubview:_titleView];
    [_webSummaryView addSubview:_playerView];
    [_webSummaryView addSubview:_descriptionView];
    
    _faviconView.translatesAutoresizingMaskIntoConstraints = NO;
    _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    _playerView.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *vs = NSDictionaryOfVariableBindings(_faviconView, _titleView, _playerView, _descriptionView);
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_faviconView(20)][_titleView]|" options:0 metrics:nil views:vs]];
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_faviconView(30)]" options:0 metrics:nil views:vs]];
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView][_descriptionView]|" options:0 metrics:nil views:vs]];
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_playerView]|" options:0 metrics:nil views:vs]];
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleView][_playerView]|" options:0 metrics:nil views:vs]];
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_descriptionView]|" options:0 metrics:nil views:vs]];
    _titleHeightConstraint = [NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    [_titleView addConstraint:_titleHeightConstraint];
    _descHeightConstraint = [NSLayoutConstraint constraintWithItem:_descriptionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
    [_descriptionView addConstraint:_descHeightConstraint];
    
    [self addSubview:_webSummaryView];
    _webSummaryView.hidden = YES;
}

- (DetailCellShowingType)getShowingTypewWithWeed:(Weed *)weed
{
    //If weed has images display images
    if (weed.images.count > 0) {
        return DetailCellShowingTypeImages;
    }
    
    NSString *youtubeUrl = [self stringURLFromYouTube];
    if (youtubeUrl) {
        return DetailCellShowingTypeVideo;
    }
    
    if (_urlDictionary.count > 0) {
        return DetailCellShowingTypeUrl;
    }
    
    return DetailCellShowingTypeDefault;
}

- (NSString *)stringURLFromYouTube
{
    for (NSString *url in [_urlDictionary allValues]) {
        if  ([url rangeOfString:@"youtube"].location != NSNotFound) {
            return url;
        }
    }
    return nil;
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

- (NSString *)videoIdWithURL:(NSURL *)url
{
    if (!url) {
        return nil;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\?.*v=([\\w]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:url.absoluteString  options:0 range:NSMakeRange(0, [url.absoluteString length])];
    NSString *videoId = nil;
    if (match) {
        NSRange videoIDRange = [match rangeAtIndex:1];
        videoId = [url.absoluteString substringWithRange:videoIDRange];
    }
    return videoId;
}

- (NSString *)cutHttpOrHttpsWithURL:(NSURL *)url
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http|https):\\/\\/)" options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex stringByReplacingMatchesInString:url.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, url.absoluteString.length) withTemplate:@""];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(pressURL:)]) {
        NSString *url = [_urlDictionary objectForKey:[self cutHttpOrHttpsWithURL:URL]];
        return [self.delegate pressURL:[NSURL URLWithString:url]];
    }
    return YES;
}

#pragma delegate WLImageCollectionView
- (CGRect)collectionview:(WLImageCollectionView *)collectionView cellRectWithIndexPath:(NSIndexPath *)indexPath
{
    WLImageCollectionViewCell *cell = (WLImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    return [collectionView convertRect:cell.frame fromView:_collectionView];
}

#pragma mark - NSURLConnectionData Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode >= 400) {
        NSLog(@"http request failed, code: %ld, reason: %@.", httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
        return;
    }
    
    NSString *videoId = [self videoIdWithURL:response.URL];
    _webSummaryView.frame = CGRectMake((self.frame.size.width - _webSummaryView.frame.size.width) * 0.5f, self.weedContentLabel.frame.origin.y + self.weedContentLabel.frame.size.height, CGRectGetWidth(_webSummaryView.frame), CGRectGetHeight(_webSummaryView.frame));
    
    [_faviconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WEB_SERVER_GET_FAVICON_URL, [self cutHttpOrHttpsWithURL:response.URL]]]];
    
    if (_type == DetailCellShowingTypeVideo) {
        NSDictionary *playerVars = @{@"playsinline":@1,
                                                             @"autohide":@1,
                                                 @"modestbranding":@1,
                                                              @"controls":@1};
        [_playerView loadWithVideoId:videoId playerVars:playerVars];
        _playerView.hidden = NO;
    }
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:_responseData];
    NSString *parseTitleString = @"/html/head/title";
    NSArray *elements = [htmlParser searchWithXPathQuery:parseTitleString];
    TFHppleElement *element = (TFHppleElement *)[elements firstObject];
    NSString *title = [[element firstChild] content];
    _titleView.text = title;
    _titleHeightConstraint.constant = [self heightOfTextView:_titleView];
    
    if (_type == DetailCellShowingTypeVideo) {
        CGFloat textLableHeight = [self getTextLableHeight:self.weedContentLabel.text];
        
        CGRect frame = _webSummaryView.frame;
        frame.size.height = [self heightOfTextView:_titleView] + CGRectGetHeight(_playerView.frame);
        CGFloat height = TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + CGRectGetHeight(_webSummaryView.frame) + 10;
        [self.delegate tableViewCell:self height:height needReload:YES];
        _webSummaryView.hidden = NO;
    }
    
    if (_type == DetailCellShowingTypeUrl) {
        NSString *parseDescString = @"/html/head/meta";
        NSArray *metaElements = [htmlParser searchWithXPathQuery:parseDescString];
        for (TFHppleElement *meta in metaElements) {
            if ([[meta.attributes objectForKey:@"name"] isEqualToString:@"description"]) {
                _descriptionView.text = [meta.attributes objectForKey:@"content"];
                _descHeightConstraint.constant = [self heightOfTextView:_descriptionView];
                _descriptionView.hidden = NO;
            }
        }
        if (_descriptionView.text.length > 0) {
            CGRect frame = _webSummaryView.frame;
            frame.size.height = [self heightOfTextView:_titleView] + [self heightOfTextView:_descriptionView];
            _webSummaryView.frame = frame;
            if (self.delegate) {
                CGFloat textLableHeight = [self getTextLableHeight:self.weedContentLabel.text];
                CGFloat height = TEXTLABLE_WEED_CONTENT_ORIGIN_Y + textLableHeight + CGRectGetHeight(_webSummaryView.frame) + 10;
                [self.delegate tableViewCell:self height:height needReload:YES];
                _webSummaryView.hidden = NO;
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Http Request failed, url: %@, error: %@", connection.description, error.localizedDescription);
    [_playerView stopVideo];
}

#pragma mark - get notification when user quit full screen display
- (void)exitFullScreen:(NSNotification *)notification
{
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    }
}

@end
