//
//  WLUIImageView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-5-4.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "WLUIImageView.h"
#import "Image.h"

@interface WLUIImageView ()

@property (nonatomic, retain) NSNumber *userId;

@end

@implementation WLUIImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        pinch.delegate = self;
        
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
        [self addGestureRecognizer:pinch];
    }
    return self;
}

- (void)setImageWithUser:(NSNumber *)userId
{
    self.userId = userId;
    [self getImageFromServerAndSetImage];
}

- (void)setImageWithWeed:(Weed *)weed
{
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    NSLog(@"tap");
//    UIView *backgroup = [[UIView alloc]initWithFrame:self.superview.bounds];
//    [backgroup setBackgroundColor:[UIColor blackColor]];
//    
//    WLUIImageView *imageView = [[WLUIImageView alloc]initWithFrame:self.superview.bounds];
//    [imageView setImageWithUser:self.userId];
//    
//    [backgroup addSubview:imageView];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    
}

- (void)getImageFromServerAndSetImage
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.userId] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Update User Avatar...");
        Image *newImage = [mappingResult.array objectAtIndex:0];
        self.image = newImage.image;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Get Avatar Failed: %@", error);
        self.image = [UIImage imageNamed:@"avatar.jpg"];
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    CALayer * l = [self layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

@end
