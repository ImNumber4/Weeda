//
//  AppDelegate.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import <RestKit/RestKit.h>
#import "Weed.h"
#import "User.h"
#import "WeedImage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

static NSString * USER_ID_COOKIE_NAME = @"user_id";
static NSString * USERNAME_COOKIE_NAME = @"username";
static NSString * PASSWORD_COOKIE_NAME = @"password";

NSString * _deviceToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupRestKit];
    [self populateCurrentUserFromCookie];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setBackgroundColor:[ColorDefinition greenColor]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[ColorDefinition greenColor]];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    // Let the device know we want to receive push notifications
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    self.badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    return YES;
}

- (void) setCurrentUser:(User *)currentUser
{
    bool userSwitched = true;
    if (_currentUser && currentUser) {
        if ([_currentUser.id isEqualToNumber:currentUser.id]) {
            userSwitched = false;
        }
    } else if (!_currentUser && !currentUser) {
        userSwitched = false;
    }
    if (userSwitched) {
        NSLog(@"user switched from %@ to %@", _currentUser.id, currentUser.id);
    }
    _currentUser = currentUser;
    if (userSwitched) {
        [self resetPersisiStores];
        [self setupRestKit];
    }
}

- (void)signout
{
    if (_deviceToken) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unregisterDevice/%@", _deviceToken] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self clearLoginCookies];
            _currentUser = nil;
            UIViewController *vc = self.window.rootViewController;
            UIViewController *controller = [vc.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
            [vc presentViewController:controller animated:YES completion:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unregisterDevice failed with error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Failed to logout. Please try again later."
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }];
    }
}

- (void) populateCurrentUserFromCookie
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return;
    }
    
    NSDate *currentTime = [NSDate date];
    NSHTTPCookie *userIdCookie = [self findCookieByName:USER_ID_COOKIE_NAME isExpiredBy:currentTime];
    NSHTTPCookie *usernameCookie = [self findCookieByName:USERNAME_COOKIE_NAME isExpiredBy:currentTime];
    NSHTTPCookie *passwordCookie = [self findCookieByName:PASSWORD_COOKIE_NAME isExpiredBy:currentTime];
    
    if (userIdCookie == nil || userIdCookie.value == nil || usernameCookie == nil || usernameCookie.value == nil || passwordCookie == nil || passwordCookie.value == nil) {
        NSLog(@"There is no available cookie.");
        return;
    }
    User * user = [User alloc];

    user.id = [NSNumber numberWithInteger:[userIdCookie.value integerValue]];
    user.username = usernameCookie.value;
    user.password = passwordCookie.value;
    self.currentUser = user;
}

- (NSHTTPCookie *) findCookieByName:(NSString *)name isExpiredBy:(NSDate *) time
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return nil;
    }
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name] && [cookie.expiresDate compare:time] == NSOrderedDescending) {
            return cookie;
        }
    }
    return nil;
}

- (void) clearLoginCookies
{
    [self removeCookieByName:USER_ID_COOKIE_NAME];
    [self removeCookieByName:USERNAME_COOKIE_NAME];
    [self removeCookieByName:PASSWORD_COOKIE_NAME];
}

- (void) removeCookieByName:(NSString *)name
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return;
    }
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void) registerDeviceToken
{
    if (_deviceToken) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/registerDevice/%@", _deviceToken] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"registerDevice failed with error: %@", error);
        }];
    }
}

- (void) resetPersisiStores
{
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@"/"];
    
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    
    [RKObjectManager sharedManager].managedObjectStore.managedObjectCache = nil;
    // Clear our object manager
    [RKObjectManager setSharedManager:nil];
    
    // Clear our default store
    [RKManagedObjectStore setDefaultStore:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [self updateBadgeCount];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"received notification as %@", [userInfo objectForKey:@"aps"]);
    NSString * badgeString = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"badge"]];
    self.badgeCount = MAX([badgeString integerValue], [UIApplication sharedApplication].applicationIconBadgeNumber);
    [self updateBadgeCount];
}

- (void) decreaseBadgeCount:(NSInteger) decreaseBy
{
    self.badgeCount = self.badgeCount - decreaseBy;
    [self updateBadgeCount];
}

- (void) updateBadgeCount
{
    if (self.notificationDelegate) {
        [self.notificationDelegate updateBadgeCount:self.badgeCount];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.badgeCount];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    _deviceToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Got device token as %@", _deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void) setupRestKit {
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-REST-API-Key" value:@"your key"];
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-Application-Id" value:@"your key"];
    
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    
    NSDictionary *parentObjectMapping = @{
                                          @"id" : @"id",
                                          @"time" : @"time",
                                          @"deleted" : @"shouldBeDeleted"
                                          };

    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    
    NSDictionary * userMappingDictionary = @{
                                                     @"id" : @"id",
                                                     @"time" : @"time",
                                                     @"username" : @"username",
                                                     @"password" : @"password",
                                                     @"email" : @"email",
                                                     @"storename" : @"storename",
                                                     @"address_street" : @"address_street",
                                                     @"address_city" : @"address_city",
                                                     @"address_state" : @"address_state",
                                                     @"address_country" : @"address_country",
                                                     @"address_zip" : @"address_zip",
                                                     @"phone" : @"phone",
                                                     @"latitude" : @"latitude",
                                                     @"longitude" : @"longitude",
                                                     @"weedCount" : @"weedCount",
                                                     @"followerCount" : @"followerCount",
                                                     @"followingCount" : @"followingCount",
                                                     @"relationshipWithCurrentUser" : @"relationshipWithCurrentUser",
                                                     @"user_type" : @"user_type",
                                                     @"has_avatar" : @"has_avatar"
                                                     };
    
    NSMutableDictionary * userResponseMappingDictionary = [NSMutableDictionary dictionaryWithDictionary:userMappingDictionary];
    [userResponseMappingDictionary setValue:@"shouldBeDeleted" forKey:@"deleted"];
    [userResponseMappingDictionary setValue:@"userDescription" forKey:@"description"];
    NSMutableDictionary * userRequestMappingDictionary = [NSMutableDictionary dictionaryWithDictionary:userMappingDictionary];
    [userRequestMappingDictionary setValue:@"deleted" forKey:@"shouldBeDeleted"];
    [userRequestMappingDictionary setValue:@"description" forKey:@"userDescription"];
    
    [userMapping addAttributeMappingsFromDictionary:userResponseMappingDictionary];
    
    RKEntityMapping *weedImageMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([WeedImage class]) inManagedObjectStore:managedObjectStore];
//    weedImageMapping.identificationAttributes = @[@"id"];
    [weedImageMapping addAttributeMappingsFromDictionary:@{@"id" : @"imageId", @"width" : @"width", @"height" : @"height"}];
    
    RKEntityMapping *weedMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Weed class]) inManagedObjectStore:managedObjectStore];
    
    weedMapping.identificationAttributes = @[ @"id" ];
    
    [weedMapping addAttributeMappingsFromDictionary:@{@"user_id" : @"user_id",
                                                      @"username" : @"username",
                                                      @"content" : @"content",
                                                      @"water_count" : @"water_count",
                                                      @"seed_count" : @"seed_count",
                                                      @"light_count" : @"light_count",
                                                      @"if_cur_user_water_it" : @"if_cur_user_water_it",
                                                      @"if_cur_user_seed_it" : @"if_cur_user_seed_it",
                                                      @"if_cur_user_light_it" : @"if_cur_user_light_it",
                                                      @"light_id" : @"light_id",
                                                      @"root_id" : @"root_id",
                                                      @"mentions" : @"mentions",
                                                      @"image_count" : @"image_count"}];
    
    [weedMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    [weedMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"images" toKeyPath:@"images" withMapping:weedImageMapping]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shouldBeDeleted = TRUE || id < 0"];
    weedMapping.deletionPredicate = predicate;
    
    RKEntityMapping *messageMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Message class]) inManagedObjectStore:managedObjectStore];
    
    messageMapping.identificationAttributes = @[ @"id" ];
    
    
    NSDictionary *messageObjectMapping = @{
                                           @"sender_id" : @"sender_id",
                                           @"participant_id" : @"participant_id",
                                           @"participant_username" : @"participant_username",
                                           @"message" : @"message",
                                           @"type" : @"type",
                                           @"is_read" : @"is_read",
                                           @"related_weed_id" : @"related_weed_id"
                                          };
    
    [messageMapping addAttributeMappingsFromDictionary:messageObjectMapping];
    [messageMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image_metadata" toKeyPath:@"image" withMapping:weedImageMapping]];
    [messageMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    messageMapping.deletionPredicate = predicate;

    
    // Register our mappings with the provider
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"weed/query"
                                                                                           keyPath:@"weeds"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"weed/queryById/:weed_id"
                                                                                               keyPath:@"weeds"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"weed/query/:user_id"
                                                                                               keyPath:@"weeds"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"weed/getLights/:id"
                                                                                               keyPath:@"weeds"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                                     method:RKRequestMethodGET
                                                                                                pathPattern:@"weed/getAncestorWeeds/:id"
                                                                                                    keyPath:@"weeds"
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"user/getUsersWaterWeed/:id"
                                                                                               keyPath:@"users"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodGET
                                                                                            pathPattern:@"user/getUsersSeedWeed/:id"
                                                                                                keyPath:@"users"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                         method:RKRequestMethodGET
                                                                                                    pathPattern:@"user/queryUsersWithCoordinates/:latitude/:longitude/:range/"
                                                                                                        keyPath:@"users"
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                                     method:RKRequestMethodGET
                                                                                                                pathPattern:@"user/queryUsersWithCoordinates/:latitude/:longitude/:range/:search_key"
                                                                                                                    keyPath:@"users"
                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                         method:RKRequestMethodGET
                                                                                                    pathPattern:@"user/getUsernamesByPrefix/:prefix"
                                                                                                        keyPath:@"users"
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                         method:RKRequestMethodGET
                                                                                                    pathPattern:@"user/getFollowingUsers/:user_id/:count"
                                                                                                        keyPath:@"users"
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                             method:RKRequestMethodGET
                                                                                                        pathPattern:@"user/getFollowers/:user_id/:count"
                                                                                                            keyPath:@"users"
                                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"user/query/:id"
                                                                                               keyPath:@"user"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"user/follow/:id"
                                                                                               keyPath:@"user"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:@"user/unfollow/:id"
                                                                                                 keyPath:@"user"
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodPOST
                                                                                             pathPattern:@"user/login"
                                                                                                keyPath:@"user"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor: [RKResponseDescriptor responseDescriptorWithMapping:messageMapping
                                                                                 method:RKRequestMethodGET
                                                                            pathPattern:@"message/query"
                                                                                keyPath:@"messages"
                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    //weed creation mapping
    RKObjectMapping * weedRequestMapping = [RKObjectMapping requestMapping];
    [weedRequestMapping addAttributeMappingsFromArray:@[ @"id", @"content",@"time",@"user_id", @"light_id", @"root_id", @"image_count", @"mentions"]];
    
    [weedRequestMapping addRelationshipMappingWithSourceKeyPath:@"images" mapping:[weedImageMapping inverseMapping]];
    
    
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:weedRequestMapping
                                                                                   objectClass:[Weed class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:weedMapping method:RKRequestMethodPOST pathPattern:@"weed/create" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    //For checking username
    RKObjectMapping *userRequestMapping = [RKObjectMapping requestMapping];
    [userRequestMapping addAttributeMappingsFromDictionary:userRequestMappingDictionary];
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping
                                                                                        objectClass:[User class]
                                                                                        rootKeyPath:nil
                                                                                             method:RKRequestMethodPOST]];

    //user creation/update mapping
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodPOST pathPattern:@"user/update" keyPath:@"errors" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"user/signup" keyPath:@"user" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    //message creation mapping
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:messageMapping method:RKRequestMethodPOST pathPattern:@"message/create" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:messageMapping method:RKRequestMethodPOST pathPattern:@"message/upload/:receiver_id" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:[messageMapping inverseMapping]
                                                                        objectClass:[Message class]
                                                                        rootKeyPath:nil
                                                                             method:RKRequestMethodPOST]];
    
    
    //Adding Image response descriptor
//    [self addImageHttpResponser:managedObjectStore];
    
    /**
     Complete Core Data stack initialization
     */
    if (!managedObjectStore.persistentStoreCoordinator) {
        [managedObjectStore createPersistentStoreCoordinator];
    }
    
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Weeda.sqlite", (self.currentUser.id == nil?@"":self.currentUser.id)]];

    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
}

- (void) addImageHttpResponser:(RKManagedObjectStore *)managedObjectStore
{
    RKObjectMapping *imageObjectMapping = [RKObjectMapping mappingForClass:[WeedImage class]];
    [imageObjectMapping addAttributeMappingsFromDictionary:@{@"id": @"id"}];
    
    RKAttributeMapping *imageMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"image" toKeyPath:@"image"];
    RKValueTransformer *imageTransformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class inputValueClass, __unsafe_unretained Class outputValueClass) {
        return ([inputValueClass isSubclassOfClass:[NSString class]] || [inputValueClass isSubclassOfClass:[UIImage class]]) && [outputValueClass isSubclassOfClass:[UIImage class]];
    } transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue, __unsafe_unretained Class outputClass, NSError *__autoreleasing *error) {
        NSData * input = (NSData *)inputValue;
        if ([input isKindOfClass:[UIImage class]]) {
            *outputValue = (UIImage *)inputValue;
        } else {
            NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:(NSString *)inputValue options:0];
            *outputValue = [UIImage imageWithData:decodeData];
        }
        return YES;
    }];
    imageMapping.valueTransformer = imageTransformer;
    [imageObjectMapping addPropertyMapping:imageMapping];
    RKResponseDescriptor *imageResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:imageObjectMapping method:RKRequestMethodGET pathPattern:@"user/avatar/:id" keyPath:@"image" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *imageWeedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:imageObjectMapping method:RKRequestMethodGET pathPattern:@"image/query/:id" keyPath:@"image" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [[RKObjectManager sharedManager] addResponseDescriptor:imageWeedResponseDescriptor];
    [[RKObjectManager sharedManager] addResponseDescriptor:imageResponseDescriptor];
}

@end
