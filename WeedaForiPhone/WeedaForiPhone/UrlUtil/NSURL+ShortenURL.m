//
//  WLURL.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 11/12/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "NSURL+ShortenURL.h"

@implementation NSURL (ShortenURL)

- (NSString *)shortenString
{
    NSString *url = self.absoluteString;
    NSError *error;
    NSString *regStrHttp = @"((http|https)://)";
    NSRegularExpression *regexHttp = [NSRegularExpression regularExpressionWithPattern:regStrHttp options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *matchHttp = [regexHttp firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
    if (matchHttp) {
        NSRange range = [matchHttp rangeAtIndex:1];
        url = [url stringByReplacingCharactersInRange:range withString:@""];
    }
    
    NSString *regStrWww = @"([\\w]*\\.)[\\w]+\\.[\\w]";
    NSRegularExpression *regexWww = [NSRegularExpression regularExpressionWithPattern:regStrWww options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *matchWww = [regexWww firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
    if (matchWww) {
        NSRange range = [matchWww rangeAtIndex:1];
        url = [url stringByReplacingCharactersInRange:range withString:@""];
    }
    
    NSUInteger length = url.length;
    if (length <= 20) {
        return url;
    }
    
    NSString *regStrNeedShorten = @"[\\w]+[\\.\\w]+/(.*)";
    NSRegularExpression *regexNeedShorten = [NSRegularExpression regularExpressionWithPattern:regStrNeedShorten options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *matchNeedShorten = [regexNeedShorten firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
    if (matchNeedShorten) {
        NSRange range = [matchNeedShorten rangeAtIndex:1];
        url = [url stringByReplacingCharactersInRange:range withString:@"~"];
    }
    
    return url;
}

@end
