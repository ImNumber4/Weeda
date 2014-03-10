#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) int id;

@end