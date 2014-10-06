//
//  WeedTableViewCell.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WeedTableViewCell.h"
#import "WeedShowImageCell.h"
#import "WeedImage.h"
#import "WeedImageController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>

#define MIN_HEIGHT_OF_TEXT_VIEW 40.0
#define DEFAULT_WEED_CONTENT_LABLE_WIDTH 200.0


@implementation WeedTableViewCell

- (void)awakeFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"WeedTableViewCell" owner:self options:nil];
    self.bounds = self.view.bounds;
    [self addSubview:self.view];
    
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    
    if (_weedTmp) {
        _weedTmp = nil;
    }
    
    _collectionView = [self createImageCollectionView:CGRectMake(0, 0, self.frame.size.width, MASTERVIEW_IMAGEVIEW_HEIGHT)];
    [self addSubview:_collectionView];
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
    self.weedContentLabel.attributedText = [[NSAttributedString alloc]initWithString:weed.content];
    self.weedContentLabel.translatesAutoresizingMaskIntoConstraints = YES;
    CGSize textLableSize = [self.weedContentLabel sizeThatFits:CGSizeMake(DEFAULT_WEED_CONTENT_LABLE_WIDTH, MIN_HEIGHT_OF_TEXT_VIEW)];
    [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, MAX(MIN_HEIGHT_OF_TEXT_VIEW, textLableSize.height))];
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", weed.username];
    [self.usernameLabel setTitle:nameLabel forState:UIControlStateNormal];
    
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
    
    [self.userAvatar sd_setImageWithURL:[WeedImageController imageURLOfAvatar:weed.user_id] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    
    if (weed.images.count > 0) {
        [_collectionView setFrame:CGRectMake(0, self.weedContentLabel.frame.origin.y + self.weedContentLabel.frame.size.height, self.frame.size.width, MASTERVIEW_IMAGEVIEW_HEIGHT)];
        _collectionView.hidden = NO;
        [_collectionView reloadData];
    } else {
        if (_collectionView) {
            _collectionView.hidden = YES;
        }
    }
}

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
    [collectionView registerNib:[UINib nibWithNibName:@"WeedShowImageCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    collectionView.showsHorizontalScrollIndicator = NO;
    
    return collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _weedTmp.images.count;
}

- (WeedShowImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeedShowImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    if (cell) {
        cell.backgroundColor = [UIColor grayColor];
        WeedImage *weedImage = [[_weedTmp.images allObjects] objectAtIndex:indexPath.row];
        [cell.imageView sd_setImageWithURL:[WeedImageController imageURLOfImageId:weedImage.url] placeholderImage:nil options:SDWebImageHandleCookies
        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            ;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                NSLog(@"Load image failed, imageId: %@, error: %@", weedImage.url, error);
            }
        }];
    } else {
        NSLog(@"Cell is nil.");
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath
                           atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                   animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath
                           atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                   animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, (self.superview.bounds.size.width - 280) / 2, 0, (self.superview.bounds.size.width - 280) / 2);
}

- (CGFloat)weedContentLableHeight:(Weed *)weed
{
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_WEED_CONTENT_LABLE_WIDTH, 44)]; //This initial size doesn't matter
    temp.font = [UIFont systemFontOfSize:12.0];
    temp.text = weed.content;
    
    CGFloat textViewWidth = DEFAULT_WEED_CONTENT_LABLE_WIDTH;
    CGRect tempFrame = CGRectMake(0, 0, textViewWidth, MIN_HEIGHT_OF_TEXT_VIEW); //The height of this frame doesn't matter.
    CGSize tvsize = [temp sizeThatFits:CGSizeMake(tempFrame.size.width, tempFrame.size.height)]; //This calculates the necessary size so that all the text fits in the necessary width.

    return MAX(tvsize.height, MIN_HEIGHT_OF_TEXT_VIEW);
}

+ (CGFloat)heightOfWeedTableViewCell:(Weed *)weed
{
    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_WEED_CONTENT_LABLE_WIDTH, 44)]; //This initial size doesn't matter
    temp.attributedText = [[NSAttributedString alloc]initWithString:weed.content];
    CGSize textLableSize = [temp sizeThatFits:CGSizeMake(DEFAULT_WEED_CONTENT_LABLE_WIDTH, MIN_HEIGHT_OF_TEXT_VIEW)];
    
    //Add the height of the other UI elements inside your cell
    if ([weed.image_count intValue] > 0) {
        return MAX(textLableSize.height, MIN_HEIGHT_OF_TEXT_VIEW) + 20.0 + MASTERVIEW_IMAGEVIEW_HEIGHT + 30.0; //For Image View
    } else {
        return MAX(textLableSize.height, MIN_HEIGHT_OF_TEXT_VIEW) + 20.0;
    }
}

@end
