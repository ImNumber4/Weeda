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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupRestKit];
    
    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    //LoginViewController *loginViewController = (LoginViewController *)navigationController.topViewController;
    //loginViewController.currentUser = currentUser;
    //MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    //controller.currentUser = currentUser;
    
    return YES;
}

- (void)setupRestKit{
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost/"]];
    
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
    
    
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"id",
                                                      @"time" : @"time",
                                                      @"deleted" : @"shouldBeDeleted",
                                                      @"username" : @"username",
                                                      @"email" : @"email",
                                                      @"weedCount" : @"weedCount",
                                                      @"followerCount" : @"followerCount",
                                                      @"followingCount" : @"followingCount",
                                                      @"relationshipWithCurrentUser" : @"relationshipWithCurrentUser",
                                                      }];

    
    RKEntityMapping *weedMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Weed class]) inManagedObjectStore:managedObjectStore];
    
    weedMapping.identificationAttributes = @[ @"id" ];
    
    [weedMapping addAttributeMappingsFromDictionary:@{@"user_id" : @"user_id", @"username" : @"username", @"content" : @"content", @"water_count" : @"water_count", @"seed_count" : @"seed_count", @"if_cur_user_water_it" : @"if_cur_user_water_it", @"if_cur_user_seed_it" : @"if_cur_user_seed_it"}];
    
    [weedMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    NSDate *now = [NSDate date];
    NSDate *fiveDaysAgo = [now dateByAddingTimeInterval:-5 * 24 * 60 * 60];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shouldBeDeleted = TRUE || id < 0 || time <= %@", fiveDaysAgo];
    weedMapping.deletionPredicate = predicate;
    
    // Register our mappings with the provider
    RKResponseDescriptor *weedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"weed/query"
                                                                                           keyPath:@"weeds"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:weedResponseDescriptor];
    
    RKResponseDescriptor *usersWaterWeedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"user/getUsersWaterWeed/:id"
                                                                                               keyPath:@"users"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [manager addResponseDescriptor:usersWaterWeedResponseDescriptor];
    
    RKResponseDescriptor *usersSeedWeedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodGET
                                                                                            pathPattern:@"user/getUsersSeedWeed/:id"
                                                                                                keyPath:@"users"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [manager addResponseDescriptor:usersSeedWeedResponseDescriptor];
    
    
    RKResponseDescriptor *userResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"user/query/:id"
                                                                                               keyPath:@"user"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:userResponseDescriptor];
    
    RKResponseDescriptor *followResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:@"user/follow/:id"
                                                                                               keyPath:@"user"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:followResponseDescriptor];
    
    RKResponseDescriptor *unfollowResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:@"user/unfollow/:id"
                                                                                                 keyPath:@"user"
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:unfollowResponseDescriptor];
    
    RKResponseDescriptor *loginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodPOST
                                                                                             pathPattern:@"user/login"
                                                                                                keyPath:@"user"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:loginResponseDescriptor];
    
    
    RKObjectMapping *userRequestMapping = [RKObjectMapping requestMapping];
    [userRequestMapping addAttributeMappingsFromArray:@[@"id"]];
    
    RKObjectMapping * weedRequestMapping = [RKObjectMapping requestMapping];
    [weedRequestMapping addAttributeMappingsFromArray:@[ @"id", @"content",@"time",@"user_id"]];
    
    
    RKRequestDescriptor *weedRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:weedRequestMapping
                                                                                   objectClass:[Weed class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    [[RKObjectManager sharedManager] addRequestDescriptor:weedRequestDescriptor];
    
    //For checking username
    RKObjectMapping * checkMapping = [RKObjectMapping requestMapping];
    [checkMapping addAttributeMappingsFromArray:@[@"username", @"password", @"email", @"time"]];
    RKRequestDescriptor *checkRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:checkMapping
                                                                                        objectClass:[User class]
                                                                                        rootKeyPath:nil
                                                                                             method:RKRequestMethodPOST];
    
    [manager addRequestDescriptor:checkRequestDescriptor];
    
    RKResponseDescriptor *signupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"user/signup" keyPath:@"user" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:signupResponseDescriptor];
    
    //For login
//    RKObjectMapping * loginMapping = [RKObjectMapping requestMapping];
//    [loginMapping addAttributeMappingsFromArray:@[ @"username", @"password"]];
//    RKRequestDescriptor *loginRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginMapping
//                                                                                        objectClass:[User class]
//                                                                                        rootKeyPath:nil
//                                                                                             method:RKRequestMethodPOST];
//    [manager addRequestDescriptor:loginRequestDescriptor];

    
    
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

@end
