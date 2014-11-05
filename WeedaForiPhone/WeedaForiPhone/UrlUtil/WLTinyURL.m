//
//  WLTinyURL.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/28/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "WLTinyURL.h"

#define TINY_URL @"http://tinyurl.com/api-create.php?url="

@implementation WLTinyURL

+ (NSString *)tinyURLWithString:(NSString *)originalURL
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", TINY_URL, originalURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *tinyURL = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return tinyURL;
}

@end
