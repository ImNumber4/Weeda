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
#import "WeedControlView.h"

#import <SDWebImage/UIImageView+WebCache.h>

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

@property (nonatomic, retain) WeedControlView *controlView;

@property (nonatomic, retain) NSLayoutConstraint *titleHeightConstraint;
@property (nonatomic, retain) NSLayoutConstraint *descHeightConstraint;
@property (nonatomic, retain) NSLayoutConstraint *playerHeightConstraint;

@property (nonatomic) DetailCellShowingType type;

@property (nonatomic, retain) NSURLConnection *connection;

@end

@implementation WeedDetailTableViewCell

static const double PADDING = 10;

static double DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1 = 250.0;
static double DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2 = 200.0;

static double DEFAULT_VIDEO_HEIGHT = 168.75f;

static double CONTROL_VIEW_HEIGHT = 30;

static double AVATAR_SIZE = 40;

static double ICON_SIZE = 15;

static double CONTENT_FONT_SIZE = 14.0;

static double FOLLOW_BUTTON_SIZE = 25;

static NSString * WEB_SERVER_GET_FAVICON_URL = @"http://www.google.com/s2/favicons?domain=";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userAvatar = [[WLImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];
        self.userAvatar.allowFullScreenDisplay = NO;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:AVATAR_SIZE/2.0];
        self.userAvatar.userInteractionEnabled = YES;
        
        [self addSubview:self.userAvatar];
        
        self.userIcon = [[UserIcon alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width - ICON_SIZE/2.0, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height - ICON_SIZE, ICON_SIZE, ICON_SIZE)];
        [self addSubview:self.userIcon];
        
        self.followButton = [[FollowButton alloc] initWithFrame:CGRectMake(self.frame.size.width - FOLLOW_BUTTON_SIZE - PADDING, self.userAvatar.center.y - FOLLOW_BUTTON_SIZE/2.0, FOLLOW_BUTTON_SIZE, FOLLOW_BUTTON_SIZE)];
        self.followButton.tintColor = [UIColor whiteColor];
        [self addSubview:self.followButton];
        
        double labelX = self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING * 2;
        self.userLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING * 2, self.userAvatar.frame.origin.y, self.followButton.frame.origin.x - labelX, self.userAvatar.frame.size.height/2.0)];
        [self.userLabel.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.userLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.userLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.userLabel addTarget:self action:@selector(showUserViewController:) forControlEvents:UIControlEventTouchDown];
        self.userLabel.userInteractionEnabled = YES;
        [self addSubview:self.userLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.userLabel.frame.origin.x, self.userLabel.frame.origin.y + self.userLabel.frame.size.height, self.userLabel.frame.size.width, self.userAvatar.frame.size.height/2.0)];
        self.timeLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self addSubview:self.timeLabel];
        
        self.weedContentLabel = [[UITextView alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height, self.frame.size.width - PADDING * 2, 30)];
        self.weedContentLabel.editable = false;
        [self.weedContentLabel setFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]];
        [self.weedContentLabel setBackgroundColor:[UIColor clearColor]];
        self.weedContentLabel.scrollEnabled = false;
        self.weedContentLabel.userInteractionEnabled = true;
        self.weedContentLabel.dataDetectorTypes = UIDataDetectorTypeAll;
        [self addSubview:self.weedContentLabel];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedContentView:)];
        [self.weedContentLabel addGestureRecognizer:tap];
        
        _imageWidthDictionary = [[NSMutableDictionary alloc]initWithCapacity:3];
        [_imageWidthDictionary setObject:[NSNumber numberWithFloat:300.0] forKey:[NSNumber numberWithInteger:EnumImageWidthTypeFull]];
        [_imageWidthDictionary setObject:[NSNumber numberWithFloat:149.0] forKey:[NSNumber numberWithInteger:EnumImageWidthTypeHalf]];
        [_imageWidthDictionary setObject:[NSNumber numberWithFloat:98.6] forKey:[NSNumber numberWithInteger:EnumImageWidthTypeOneThird]];
        
        _adjustedCellSize = [NSMutableArray new];
        _urlDictionary = [NSMutableDictionary new];
        _dataSource = [[NSArray alloc]init];
        
        _collectionView = [self createCollectionViewWithRect:CGRectMake(0, 0, self.frame.size.width, DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1)];
        _collectionView.scrollEnabled = false;
        [self addSubview:_collectionView];
        _collectionView.hidden = YES;
        _controlView = [[WeedControlView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CONTROL_VIEW_HEIGHT) isSimpleMode:false];
    }
    return self;
}

- (void)tappedContentView:(UIGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(selectWeedContent:)]) {
        [self.delegate selectWeedContent:recognizer];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)decorateCellWithWeed:(Weed *)weed parentViewController:(UIViewController *) parentViewController showHeader:(BOOL) showHeader
{
    self.weed = weed;
    [self.urlDictionary removeAllObjects];
    NSString *content = [WeedDetailTableViewCell shortenURLInContent:weed.content urlDictionary:self.urlDictionary];
    
    if (showHeader) {
        self.userAvatar.hidden = FALSE;
        self.userLabel.hidden = FALSE;
        self.timeLabel.hidden = FALSE;
        self.followButton.hidden = FALSE;
        self.userIcon.hidden = FALSE;
        [self.userIcon setUserType:weed.user_type];
        
        NSString *username = weed.username;
        NSString *nameLabel = [NSString stringWithFormat:@"@%@", username];
        [self.userLabel setTitle:nameLabel forState:UIControlStateNormal];
        
        [self.userAvatar setImageURL:[WeedImageController imageURLOfAvatar:weed.user_id] isAvatar:YES];
        [self.followButton setUser_id:weed.user_id relationshipWithCurrentUser:weed.user_relationship_with_currentUser];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. dd yyyy hh:mm"];
        NSString *formattedDateString = [dateFormatter stringFromDate:weed.time];
        self.timeLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
        
        [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, [WeedDetailTableViewCell getTextLableHeight:content])];
    } else {
        self.userAvatar.hidden = TRUE;
        self.userLabel.hidden = TRUE;
        self.timeLabel.hidden = TRUE;
        self.followButton.hidden = TRUE;
        self.userIcon.hidden = TRUE;
        [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, 0, self.weedContentLabel.frame.size.width, [WeedDetailTableViewCell getTextLableHeight:content])];
    }
    
    self.weedContentLabel.text = content;
    self.weedContentLabel.delegate = self;
    self.weedContentLabel.translatesAutoresizingMaskIntoConstraints = YES;
    

    _type = [WeedDetailTableViewCell getShowingTypeWithWeed:weed];
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
            NSString *videoUrl = [WeedDetailTableViewCell stringURLFromYouTube:self.urlDictionary];
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
    [_controlView setFrame:CGRectMake(0, self.frame.size.height - CONTROL_VIEW_HEIGHT, self.frame.size.width, CONTROL_VIEW_HEIGHT)];
    [_controlView decorateWithWeed:weed parentViewController:parentViewController];
    [self addSubview:self.controlView];

    [self createWebSummaryView];
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
+ (CGFloat)heightForCell:(Weed*) weed showHeader:(BOOL) showHeader
{
    CGFloat height = 0;
    double weedContentLabelY = showHeader?PADDING + AVATAR_SIZE:0;
    CGFloat textLableHeight = [self getTextLableHeight:weed.content];
    switch ([WeedDetailTableViewCell getShowingTypeWithWeed:weed]) {
        case DetailCellShowingTypeImages:
            height = [weed.image_count intValue] < 3 ? weedContentLabelY + textLableHeight + DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT2 : weedContentLabelY + textLableHeight + DEFAULT_IMAGE_DISPLAY_BOARD_HEIGHT1;
            break;
        case DetailCellShowingTypeVideo:
        case DetailCellShowingTypeUrl:
            height = weedContentLabelY + textLableHeight;
            break;
        default:
            height = weedContentLabelY + textLableHeight;
            break;
    }
    height += CONTROL_VIEW_HEIGHT;
    return height;
}

+ (CGFloat)getTextLableHeight:(NSString *)text
{
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:CONTENT_FONT_SIZE];
    temp.text = text;
    
    CGFloat textViewWidth = [[UIScreen mainScreen] bounds].size.width - 2 * PADDING;
    CGRect tempFrame = CGRectMake(0, 0, textViewWidth, 40); //The height of this frame doesn't matter.
    CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.
    
    return tvsize.height;
}

- (CGFloat)heightOfTextView:(UITextView *)textView
{
    CGFloat width = CGRectGetWidth(textView.frame);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width, 44.0f)];
    return newSize.height;
}

- (void)createWebSummaryView
{
    _webSummaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.weedContentLabel.frame.size.width, DEFAULT_VIDEO_HEIGHT + 20 + 10)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedContentView:)];
    [_webSummaryView addGestureRecognizer:tap];
    _faviconView = [UIImageView new];
    _faviconView.contentMode = UIViewContentModeCenter;
    
    _titleView = [UITextView new];
    [_titleView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    _titleView.editable = NO;
    _titleView.selectable = NO;
    _titleView.scrollEnabled = NO;
    _titleView.textColor = [UIColor darkGrayColor];
    _titleView.font = self.weedContentLabel.font;
    [_titleView setBackgroundColor:[UIColor clearColor]];
    
    _descriptionView = [UITextView new];
    [_descriptionView setBackgroundColor:[UIColor clearColor]];
    _descriptionView.editable = NO;
    _descriptionView.selectable = NO;
    _descriptionView.hidden = YES;
    _descriptionView.scrollEnabled = NO;
    _descriptionView.textColor = [UIColor darkGrayColor];
    _descriptionView.font = self.weedContentLabel.font;
    [_webSummaryView addSubview:_descriptionView];
    
    _playerView = [YTPlayerView new];
    _playerView.delegate = self;
    _playerView.hidden = YES;
    [_webSummaryView addSubview:_playerView];
    
    [_webSummaryView addSubview:_faviconView];
    [_webSummaryView addSubview:_titleView];
    
    _faviconView.translatesAutoresizingMaskIntoConstraints = NO;
    _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    _playerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *vs = NSDictionaryOfVariableBindings(_faviconView, _titleView, _playerView, _descriptionView);
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_faviconView(20)][_titleView]|" options:0 metrics:nil views:vs]];
    [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_faviconView(30)]" options:0 metrics:nil views:vs]];
    _titleHeightConstraint = [NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    [_titleView addConstraint:_titleHeightConstraint];
    
    if (_type == DetailCellShowingTypeVideo) {
        [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView][_playerView]|" options:0 metrics:nil views:vs]];
        [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_playerView]|" options:0 metrics:nil views:vs]];
        _playerHeightConstraint = [NSLayoutConstraint constraintWithItem:_playerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [_playerView addConstraint:_playerHeightConstraint];
    }
    if (_type == DetailCellShowingTypeUrl) {
        [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView][_descriptionView]|" options:0 metrics:nil views:vs]];
        [_webSummaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_descriptionView]|" options:0 metrics:nil views:vs]];
        _descHeightConstraint = [NSLayoutConstraint constraintWithItem:_descriptionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [_descriptionView addConstraint:_descHeightConstraint];
    }
    
    [self addSubview:_webSummaryView];
    _webSummaryView.hidden = YES;
}

+ (DetailCellShowingType)getShowingTypeWithWeed:(Weed *)weed
{
    //If weed has images display images
    if (weed.images.count > 0) {
        return DetailCellShowingTypeImages;
    }
    NSMutableDictionary * tempUrlDictionary = [NSMutableDictionary new];
    [WeedDetailTableViewCell shortenURLInContent:weed.content urlDictionary:tempUrlDictionary];
    NSString *youtubeUrl = [WeedDetailTableViewCell stringURLFromYouTube:tempUrlDictionary];
    if (youtubeUrl) {
        return DetailCellShowingTypeVideo;
    }
    
    if (tempUrlDictionary.count > 0) {
        return DetailCellShowingTypeUrl;
    }
    
    return DetailCellShowingTypeDefault;
}

+ (NSString *)stringURLFromYouTube:(NSMutableDictionary *) urlDictionary
{
    for (NSString *url in [urlDictionary allValues]) {
        if  ([url rangeOfString:@"youtube"].location != NSNotFound) {
            return url;
        }
    }
    return nil;
}

+ (NSString *)shortenURLInContent:(NSString *)content urlDictionary:(NSMutableDictionary *) urlDictionary
{
    if (!content) {
        return content;
    }
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc]initWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *results = [detector matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *result in results) {
        if (result.URL) {
            NSString *url = result.URL.shortenString;
            [urlDictionary setObject:result.URL.absoluteString forKey:url];
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
        _playerHeightConstraint.constant = DEFAULT_VIDEO_HEIGHT;
        
        CGRect frame = _webSummaryView.frame;
        frame.size.height = [self heightOfTextView:_titleView] + DEFAULT_VIDEO_HEIGHT;
        _webSummaryView.frame = frame;
        CGFloat height = [WeedDetailTableViewCell heightForCell:self.weed showHeader:!self.userAvatar.isHidden] + CGRectGetHeight(_webSummaryView.frame);
        [self callDelegateToUpdateCellHeight:height];
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
                CGFloat height = [WeedDetailTableViewCell heightForCell:self.weed showHeader:!self.userAvatar.isHidden] + CGRectGetHeight(_webSummaryView.frame);
                [self callDelegateToUpdateCellHeight:height];
                _webSummaryView.hidden = NO;
            }
        }
    }
}

- (void) callDelegateToUpdateCellHeight:(CGFloat)height
{
    [self.controlView setFrame:CGRectMake(0, height - CONTROL_VIEW_HEIGHT, self.frame.size.width, CONTROL_VIEW_HEIGHT)];
    [self.delegate tableViewCell:self height:height needReload:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Http Request failed, url: %@, error: %@", connection.description, error.localizedDescription);
    [_playerView stopVideo];
}

@end
