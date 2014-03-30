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
                                          @"deleted" : @"deleted"
                                          };
    
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([User class]) inManagedObjectStore:manager.managedObjectStore];
    
    userMapping.identificationAttributes = @[ @"id" ];
    
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"username" : @"username",
                                                      @"email" : @"email",
                                                      }];
    
    [userMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    RKEntityMapping *weedMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Weed class]) inManagedObjectStore:managedObjectStore];
    
    weedMapping.identificationAttributes = @[ @"id" ];
    
    [weedMapping addAttributeMappingsFromDictionary:@{@"content" : @"content"}];
    
    [weedMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    [weedMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    
    // Register our mappings with the provider
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:weedMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"weed/query"
                                                                                           keyPath:@"weeds"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    [manager addResponseDescriptor:responseDescriptor];
    
    RKObjectMapping *userRequestMapping = [RKObjectMapping requestMapping];
    [userRequestMapping addAttributeMappingsFromArray:@[@"username"]];
    
    RKObjectMapping * weedRequestMapping = [RKObjectMapping requestMapping];
    [weedRequestMapping addAttributeMappingsFromArray:@[ @"id", @"content",@"time"]];
    
    [weedRequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userRequestMapping]];
    
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:weedRequestMapping
                                                                                   objectClass:[Weed class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    [[RKObjectManager sharedManager] addRequestDescriptor:requestDescriptor];
    

    [[RKObjectManager sharedManager] addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        NSDate *now = [NSDate date];
        NSDate *twoDaysAgo = [now dateByAddingTimeInterval:2 * 24 * 60 * 60];
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"weed/query"];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Weed"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deleted = true OR time <= %@", twoDaysAgo];
            fetchRequest.predicate = predicate;
            fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES] ];
            return fetchRequest;
        }
        return nil;
    }];
    
    
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
