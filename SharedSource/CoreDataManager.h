//
//  CoreDataManager.h
//  Prototype01
//
//  Created by Cody Sandel on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "cocos2d.h"

@interface CoreDataManager : NSObject {
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

//
// properties
//
@property (nonatomic, retain) NSManagedObjectModel *_managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *_managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *_persistentStoreCoordinator;

//
// static functions
//
+ (CoreDataManager *)coreDataManager;
+ (void)setSharedCoreDataManager:(CoreDataManager *)aCoreDataManager;
+ (CoreDataManager *)sharedCoreDataManager;

//
// initialization
//
- (id)init;
- (int)initManagedObjectContext;
- (int)initPersistentCoordinator;

//
// misc
//
- (NSEntityDescription *)getEntity:(NSString *)entityName;
- (NSArray *)fetchDataFrom:(NSString *)entityName 
             withPredicate:(NSPredicate *)predicate;
- (void)truncateEntity:(NSString *)entityName;
- (int)commitData;

//
// cleanup
//
- (void)dealloc;


@end
