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
    
    self.weedImages = [[NSMutableArray alloc]init];
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
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    self.weedContentLabel.text = weed.content;
    [self.weedContentLabel setFrame:CGRectMake(self.weedContentLabel.frame.origin.x, self.weedContentLabel.frame.origin.y, self.weedContentLabel.frame.size.width, self.weedContentLabel.contentSize.height)];
    
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
    
    if ([weed.image_count intValue] > 0) {
        for (int i = 0; i < [weed.image_count intValue]; i++) {
            [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[WeedImageController imageURLOfWeedId:weed.id userId:weed.user_id count:i] options:SDWebImageDownloaderHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                UIImage *newImage = [WeedImageController imageWithImage:image scaledToHeight:200.0];
//                NSLog(@"Image size, width: %f, height: %f.", newImage.size.width, newImage.size.height);
                if (image && finished) {
                    [self.weedImages addObject:image];
                    if (self.weedImages.count == [weed.image_count intValue]) {
                        [self.imageCollectionView reloadData];
                    }
                }
                
            }];
        }
        
        [self createImageCollectionView];
        
        self.imageCollectionView.center = CGPointMake(320 / 2, self.view.frame.size.height - 20 - 10 - self.imageCollectionView.frame.size.height / 2);
        
        
    }
}

- (void)createImageCollectionView
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(280, 200);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(0, (self.superview.bounds.size.width - layout.itemSize.width) / 2, 0, (self.superview.bounds.size.width - layout.itemSize.width) / 2);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.imageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 320, 230) collectionViewLayout:layout];
    [self.imageCollectionView setDelegate:self];
    [self.imageCollectionView setDataSource:self];
    [self.imageCollectionView registerNib:[UINib nibWithNibName:@"WeedShowImageCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    [self.imageCollectionView setBackgroundColor:[UIColor whiteColor]];
    
//    CGFloat collectionViewHeight = CGRectGetHeight(self.imageCollectionView.bounds);
//    [self.imageCollectionView setContentInset:UIEdgeInsetsMake(collectionViewHeight/2, 0, collectionViewHeight/2, 0) ];
    
    [self addSubview:self.imageCollectionView];
//    self.imageCollectionView.hidden = YES;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.weedImages.count;
}

- (WeedShowImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeedShowImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    if (cell) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.imageView.image = [self.weedImages objectAtIndex:[indexPath row]];
    }
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UIImage *image = [self.weedImages objectAtIndex:[indexPath row]];
//    NSLog(@"cell size, width: %f, height: %f.", image.size.width, image.size.height);
//    return image.size;
//}

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

@end
