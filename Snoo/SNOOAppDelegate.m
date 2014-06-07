//
//  SNOOAppDelegate.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOAppDelegate.h"
#import "SNOORedditService.h"

#define SNOO_CORE_DATA_STORE_FILENAME @"Snoo.sqlite"

@interface SNOOAppDelegate ()
@property( nonatomic, strong ) SNOORedditService *redditService ;
@end

@implementation SNOOAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	// Set up the Reddit service
	self.redditService = [SNOORedditService new] ;
	
    return YES;
	}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	return YES ;
	}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
	{
    return NO;
	}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
	{
    return NO;
	}


#pragma mark - Core Data stack


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.



- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]; // http://www.cocoanetics.com/2012/07/multi-context-coredata/
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Snoo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
	{
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:SNOO_CORE_DATA_STORE_FILENAME];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
		{
		// Because Core Data is only used as a local cache, if anything goes wrong with it (say there's a schema update), we can just delete the curent file and make a new one
		NSLog(@"Could not instantiate PSC: %@" , error) ;

		// Delete the database
		NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:SNOO_CORE_DATA_STORE_FILENAME] ;
		NSLog(@"Deleting the store and trying again.") ;
		NSError *deleteError = nil ;
		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:&deleteError] ;
		if( !deleteError )
			{
			_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
			if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
				{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internal Oopsie Error" message:@"I could not initialize my brains. This is bad. You could try deleting this app and re-installing it from the App Store." delegate:nil cancelButtonTitle:@"Tilt" otherButtonTitles:nil] ;
				[alert show] ;
				}
			}
		else
			{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internal Oopsie Error" message:@"I could not initialize my brains. This is bad. Try deleting this app and re-installing it from the App Store." delegate:nil cancelButtonTitle:@"Tilt" otherButtonTitles:nil] ;
			[alert show] ;
			}
		}
    
    return _persistentStoreCoordinator;
	}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - UIResponder

- (UIResponder *) nextResponder
	{
	return self.redditService ;
	}

@end


@implementation UIApplication (Convenience)

+ (SNOOAppDelegate *) snooAppDelegate
	{
	return [[UIApplication sharedApplication] delegate] ;
	}

@end

