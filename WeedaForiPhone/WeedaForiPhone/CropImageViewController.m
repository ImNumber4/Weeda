//
//  SquareImageViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-27.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "CropImageViewController.h"

@interface CropImageViewController () <UIGestureRecognizerDelegate> {

}
@property (weak, nonatomic) IBOutlet UIView *cropBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinch;
@property (nonatomic, weak) UIPanGestureRecognizer   *pan;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) WLCropImageMaskView *maskView;

//For imageView animation
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) CGRect originalFrame;

@end

@implementation CropImageViewController

@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.maskView = [[WLCropImageMaskView alloc] initWithFrame:CGRectMake(0, 0, self.cropBackgroundView.bounds.size.width, self.cropBackgroundView.bounds.size.height)];
    [self.maskView setBackgroundColor:[UIColor clearColor]];
    [self.maskView setUserInteractionEnabled:NO];
    [self.maskView setCropSize:CGSizeMake(AVATAR_CROP_SIZE_WIDTH, AVATAR_CROP_SIZE_HEIGHT)];
    [self.cropBackgroundView addSubview:self.maskView];
    
    UIImage *newImage = [self imageWithImage:self.image scaledToSize:CGSizeMake(AVATAR_CROP_SIZE_WIDTH + 5, AVATAR_CROP_SIZE_HEIGHT + 5)];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.maskView.cropBounds.origin.x, self.maskView.cropBounds.origin.y, newImage.size.width, newImage.size.height)];
    //adjust imageView position
    self.imageView.center = self.maskView.center;
    // Set image to imageView
    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = newImage;
    [self.cropBackgroundView addSubview:self.imageView];
    
    [self.cropBackgroundView bringSubviewToFront:self.maskView];
    
    // create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.imageView addGestureRecognizer:pan];
    self.pan = pan;
    
    // create pan gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.imageView addGestureRecognizer:pinch];
    self.pinch = pinch;
}

- (UIImage*)imageWithImage:(UIImage*)originalImage
              scaledToSize:(CGSize)size;
{
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat ratio = width / height;
    
    CGSize newSize;
    
    if (width > height) {
        newSize = CGSizeMake(size.height * ratio, size.height);
    } else {
        newSize = CGSizeMake(size.width, size.width / ratio);
    }
    
    UIGraphicsBeginImageContext( newSize );
    [originalImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Gesture recognizers

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    UIView *oldImage = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.originalCenter = gesture.view.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = [gesture translationInView: oldImage.superview];
        CGPoint c = oldImage.center;
        c.x += delta.x; c.y += delta.y;
        oldImage.center = c;
        [gesture setTranslation: CGPointZero inView: oldImage.superview];
        if ([self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            self.originalCenter = oldImage.center;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (![self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            [UIView animateWithDuration:0.5 animations:^{
                gesture.view.center = self.originalCenter;
            }];
        }
    } else {
        NSLog(@"Pinch failed, reason: %ld", gesture.state);
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.originalFrame = gesture.view.frame;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        gesture.view.transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
        if ([self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            self.originalFrame = gesture.view.frame;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (![self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            [UIView animateWithDuration:0.5 animations:^{
                self.imageView.frame = self.originalFrame;
            }];
        }
    } else {
        NSLog(@"Pinch failed, reason: %ld", gesture.state);
    }
    
}

- (BOOL)isFillFrame:(CGRect)frame currentImageFrame:(CGRect)currentFrame
{
    CGFloat boundA = currentFrame.origin.x;
    CGFloat boundB = currentFrame.origin.y;
    CGFloat boundC = currentFrame.origin.x + currentFrame.size.width;
    CGFloat boundD = currentFrame.origin.y + currentFrame.size.height;
    
    if (boundA > frame.origin.x
        || boundB > frame.origin.y
        || boundC < (frame.origin.x + frame.size.width)
        || boundD < (frame.origin.y + frame.size.height)) {
        return NO;
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.pan   && otherGestureRecognizer == self.pinch) ||
        (gestureRecognizer == self.pinch && otherGestureRecognizer == self.pan))
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)selected:(id)sender
{
    NSLog(@"Crop Image");
    CGRect frameRect = self.imageView.frame;
    UIImage *newImage = [self imageWithImage:self.image scaledToSize:frameRect.size];
    CGRect rect = CGRectMake(self.maskView.cropBounds.origin.x - frameRect.origin.x, self.maskView.cropBounds.origin.y - frameRect.origin.y, self.maskView.cropBounds.size.width, self.maskView.cropBounds.size.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], rect);
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
    [self.delegate addItemViewContrller:self didFinishCropImage:cropImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)canceled:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

@implementation WLCropImageMaskView

- (void)setCropSize:(CGSize)size {
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _cropRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGSize)cropSize {
    return _cropRect.size;
}

- (CGRect)cropBounds {
    return _cropRect;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 0, .4);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, 2.0f);
    
    CGContextClearRect(ctx, _cropRect);
}

@end
