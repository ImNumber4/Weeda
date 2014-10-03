//
//  AppDelegate.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "LoginViewController.h"
#import <RestKit/RestKit.h>
#import "Weed.h"
#import "User.h"
#import "WeedImage.h"
#import "ImageMetadata.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupRestKit];
    
    // Let the device know we want to receive push notifications
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    self.deviceToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)setupRestKit{
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://www.cannablaze.com/"]];
    
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
    [errorMapping addPropertyMapping:
    [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    
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
    
    RKEntityMapping *metadataMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([ImageMetadata class]) inManagedObjectStore:managedObjectStore];
    metadataMapping.identificationAttributes = @[@"url"];
    [metadataMapping addAttributeMappingsFromDictionary:@{@"url" : @"url", @"width" : @"width", @"height" : @"height"}];
    [metadataMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
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
                                                      @"image_count" : @"image_count"}];
    
    [weedMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    [weedMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image_metadata" toKeyPath:@"image_metadata" withMapping:metadataMapping]];
    
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
    [weedRequestMapping addAttributeMappingsFromArray:@[ @"id", @"content",@"time",@"user_id", @"light_id", @"root_id", @"image_count"]];
    
    
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
    
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:[messageMapping inverseMapping]
                                                                        objectClass:[Message class]
                                                                        rootKeyPath:nil
                                                                             method:RKRequestMethodPOST]];
    
    
    //Adding Image response descriptor
    [self addImageHttpResponser:managedObjectStore];
    
    /**
     Complete Core Data stack initialization
     */
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Weeda.sqlite"];
    
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
    [imageObjectMapping addAttributeMappingsFromDictionary:@{@"url": @"url"}];
    
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
