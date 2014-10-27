//
//  TermsAndPoliciesViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/24/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "TermsAndPoliciesViewController.h"

@interface TermsAndPoliciesViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation TermsAndPoliciesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Terms and Policies";
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    //Need to update the url
    NSString *strURL = @"https://twitter.com/tos";
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
