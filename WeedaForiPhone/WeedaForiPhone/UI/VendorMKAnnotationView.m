//
//  VendorMKAnnotationView.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 6/29/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "VendorMKAnnotationView.h"

@implementation VendorMKAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [self getImage:@"dispensary_icon.png" width:30 height:30];
        self.canShowCallout = NO;
        self.enabled = YES;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        if (!self.calloutView) {
            CGRect viewRect = CGRectMake(30, -10, 160, 50);
            self.calloutView = [[VendorCallOutView alloc] initWithFrame:viewRect];
            self.calloutView.storename.userInteractionEnabled = YES;
            self.calloutView.address.userInteractionEnabled = YES;
            self.calloutView.phone.userInteractionEnabled = YES;
            [self.calloutView.storename addTarget:self action:@selector(viewPressed:)forControlEvents:UIControlEventTouchDown];
            [self.calloutView.phone addTarget:self action:@selector(phoneClicked:)forControlEvents:UIControlEventTouchDown];
            [self.calloutView.direction addTarget:self action:@selector(directionClicked:)forControlEvents:UIControlEventTouchDown];
        }
        if ([self.annotation isKindOfClass:[User class]]) {
            User * user = (User *)self.annotation;
            if (user.phone) {
                self.calloutView.phone.enabled = YES;
                self.calloutView.phone.backgroundColor = [ColorDefinition greenColor];
            }else{
                self.calloutView.phone.enabled = NO;
                self.calloutView.phone.backgroundColor = [ColorDefinition grayColor];
            }
            self.calloutView.direction.backgroundColor = [ColorDefinition blueColor];
            [self.calloutView.storename setTitle:user.storename forState:UIControlStateNormal];
            self.calloutView.address.text = [NSString stringWithFormat:@"%@, %@, %@, %@", user.address_street, user.address_city, user.address_state, user.address_zip];
        }
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == nil && self.selected) {
        CGPoint pointInAnnotationView = [self convertPoint:point toView:self.calloutView];
        UIView *calloutView = self.calloutView.view;
        hitView = [calloutView hitTest:pointInAnnotationView withEvent:event];
    }
    return hitView;
}


- (void) directionClicked:(id)sender {
    [[((User *)self.annotation) mapItem] openInMapsWithLaunchOptions:nil];
}

- (void) viewPressed:(UIGestureRecognizer *)sender {
    [self.delegate annotationPressed:self];
}

- (void) phoneClicked:(id)sender {
    NSURL *URL = [NSURL URLWithString: [NSString stringWithFormat:@"tel://%@", ((User *)self.annotation).phone]];
    [[UIApplication sharedApplication] openURL:URL];
}


- (UIImage *)getImage:(NSString *)imageName width:(int)width height:(int) height
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
