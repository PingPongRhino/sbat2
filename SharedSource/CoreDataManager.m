//
//  CoreDataManager.m
//  Prototype01
//
//  Created by Cody Sandel on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CoreDataManager.h"

//
// static variables
//
CoreDataManager *_sharedCoreDataManager;


@implementation CoreDataManager

//
// synthesize
//
@synthesize _managedObjectModel;
@synthesize _managedObjectContext;
@synthesize _persistentStoreCoordinator;

//
//
//
+ (CoreDataManager *)coreDataManager {
    CoreDataManager *coreDataManager = [[[CoreDataManager alloc] init] autorelease];
    return coreDataManager;
}

//
//
//
+ (void)setSharedCoreDataManager:(CoreDataManager *)aCoreDataManager {
    _sharedCoreDataManager = aCoreDataManager;
}

//
//
//
+ (CoreDataManager *)sharedCoreDataManager {
    return _sharedCoreDataManager;
}

//
//
//
- (id)init {
    self = [super init];
    self._managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    [self initPersistentCoordinator];
    [self initManagedObjectContext];
    return self;
}

//
//
//
- (int)initManagedObjectContext {
    if (_persistentStoreCoordinator == nil) {
        NSLog(@"Persistent Store Coordinator is nil");
        return -1;
    }
    
    self._managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    return 0;
}

//
//
//
- (int)initPersistentCoordinator {
    
    NSString *appDocDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeUrl = [NSURL fileURLWithPath:[appDocDir stringByAppendingPathComponent:@"Prototype01.sqlite"]];
    
    NSError *error = nil;
    self._persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel] autorelease];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // TODO: Replace this implementation with code to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        return -1;
    }
    
    return 0;
}

//
//
//
- (NSEntityDescription *)getEntity:(NSString *)entityName {
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
}

//
// desc: fetch all the data from a specified entity
//
// params: entityName[in] - name of entity to get all objects from
//         predicate[in] - predicate to be used to filter results
//
// returns: returns array of records if successful
//          returns nil if fetch failed
//
- (NSArray *)fetchDataFrom:(NSString *)entityName 
             withPredicate:(NSPredicate *)predicate {
	
	// alloc fetch request
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		
	// set the entity to fetch from
	NSEntityDescription *entity = [self getEntity:entityName];
	[fetchRequest setEntity:entity];
	
	// set predicate
	[fetchRequest setPredicate:predicate];
	
	// don't worry about sorting
	[fetchRequest setSortDescriptors:nil];
	
	// get results in a mutable array
	NSError *error = nil;
	NSArray *array = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	// check to see if we were successful
	if (array == nil) {
		NSLog(@"Fetch failed: %@", [error localizedDescription]);
	}
	
	return array; // return success
}

//
//
//
- (void)truncateEntity:(NSString *)entityName {
    NSArray *managedObjects = [self fetchDataFrom:entityName withPredicate:nil];
    
    for (int i=0; i < [managedObjects count]; i++) {
        NSManagedObject *managedObject = [managedObjects objectAtIndex:i];
        [_managedObjectContext deleteObject:managedObject];
    }
    
    [self commitData];
}

//
//
//
- (int)commitData {
    
    // commit and final data to core data
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        return -1;
    }
    return 0;
}

//
//
//
- (void)dealloc {
    // if any outstanding data, go ahead and commit it
    [self commitData];
    
    self._managedObjectModel = nil;
    self._managedObjectContext = nil;
    self._persistentStoreCoordinator = nil;
    [super dealloc];
}

@end
