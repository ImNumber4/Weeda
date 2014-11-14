//
//  WLWebViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/29/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLWebViewController.h"
#import "WLActionSheet.h"

#define OPEN_WITH_MAIL @"Mail Link"
#define OPEN_WITH_SAFARI @"Open With Safari"

@interface WLWebViewController () <UIWebViewDelegate, UIAlertViewDelegate, WLActionSheetDelegate>

@property (nonatomic, retain) UIProgressView *progressView;

@property (nonatomic, retain) UIWebView *webView;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) BOOL hasFinishLoading;

@end

@implementation WLWebViewController

@synthesize url;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithImage:[self getImage:@"web_close.png" width:20 height:20] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    UIBarButtonItem *openWithButton = [[UIBarButtonItem alloc]initWithImage:[self getImage:@"open_by_others" width:20 height:20] style:UIBarButtonItemStylePlain target:self action:@selector(openWith:)];
    [self.navigationItem setTitle:@"Smoking..."];
    [self.navigationItem setLeftBarButtonItem:closeButton];
    [self.navigationItem setRightBarButtonItem:openWithButton];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) + 50)];
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.bounces = NO;
    [self.view addSubview:_webView];
    
    _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.tintColor = [ColorDefinition greenColor];
    _progressView.trackTintColor = [ColorDefinition grayColor];
    _progressView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 1);
    [self.view addSubview:_progressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!url) {
        NSLog(@"Error: Web Content Loading Failed, url is null");
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Oops..." message:@"URL is invalid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
//    NSURL *test = [[NSURL alloc]initWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0f];
    [_webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([_webView isLoading]) {
        [_webView stopLoading];
    }
}

#pragma mark - UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
    self.navigationItem.title = title;

    [self finishLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error: Web Content Loading Failed, %@", error);
    [self finishLoading];
    //Notify user loading failed
    if (error.code != NSURLErrorCancelled) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Oops..."
                                                    message:[NSString stringWithFormat:@"%@", error.localizedDescription]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [av show];
    }

}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        [self close:self];
    }
}

#pragma mark - ActionSheet delegate
- (void)actionSheet:(WLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonString isEqualToString:OPEN_WITH_MAIL]) {
        NSString *subject = @"mailto:?subject=Share Link From Cannablaze";
        NSString *body = [NSString stringWithFormat:@"&body=%@", url];
        NSString *email = [NSString stringWithFormat:@"%@%@", subject, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
    if ([buttonString isEqualToString:OPEN_WITH_SAFARI]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Navigation
- (void)close:(id)sender
{
    if ([_webView isLoading]) {
        [_webView stopLoading];
    }
    [self finishLoading];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBarController.tabBar.alpha = 1.0;
    }];
    
    CATransition*transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)openWith:(id)sender
{
    WLActionSheet *as = [[WLActionSheet alloc]initWithTitle:nil
                                                                            delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                              otherButtonTitles:OPEN_WITH_MAIL, OPEN_WITH_SAFARI, nil];
    [as showInView:_webView];
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - private
- (UIImage *)getImage:(NSString *)imageName width:(int)width height:(int) height
{
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize sacleSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}

-(void)startLoading {
    _progressView.progress = 0;
    _hasFinishLoading = NO;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}
-(void)finishLoading {
    _hasFinishLoading = YES;
}
-(void)timerCallback {
    if (_hasFinishLoading) {
        if (_progressView.progress >= 1) {
            _progressView.hidden = YES;
            [_timer invalidate];
            _timer = nil;
        }
        else {
            _progressView.progress += 0.1;
        }
    }
    else {
        _progressView.progress += 0.01;
        if (_progressView.progress >= 0.95) {
            _progressView.progress = 0.95;
        }
    }
}

@end
