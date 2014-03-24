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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupRestKit];
    
    return YES;
}

- (void)setupRestKit{
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost/"]];
    
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-REST-API-Key" value:@"your key"];
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-Application-Id" value:@"your key"];
    
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:
     [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping pathPattern:nil keyPath:@"error" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [manager addResponseDescriptorsFromArray:@[errorDescriptor]];
    NSDictionary *parentObjectMapping = @{
                                          @"id" : @"id",
                                          @"time" : @"time"
                                          };
    
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([User class]) inManagedObjectStore:manager.managedObjectStore];
    
    userMapping.identificationAttributes = @[ @"id" ];
    
    [userMapping addAttributeMappingsFromDictionary:@{
                                                          @"username" : @"username",
                                                          @"email" : @"email",
                                                          }];
    
    [userMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    [manager addResponseDescriptorsFromArray:@[
                                               [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                       pathPattern:@"user/query"
                                                                                           keyPath:@"users"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]]];
    
    RKEntityMapping *weedMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Weed class]) inManagedObjectStore:managedObjectStore];
    
    weedMapping.identificationAttributes = @[ @"id" ];
    
    [weedMapping addAttributeMappingsFromDictionary:@{
                                                           @"content" : @"content"
                                                           }];
    
    [weedMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    [weedMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    
    [manager addResponseDescriptorsFromArray:@[
                                               
                                               [RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                       pathPattern:@"weed/query"
                                                                                           keyPath:@"weeds"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
                                               ]];
    

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
