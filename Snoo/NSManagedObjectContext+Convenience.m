//
//  NSManagedObjectContext+Convenience.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "NSManagedObjectContext+Convenience.h"

@implementation NSManagedObjectContext (Convenience)

- (void) saveRecursively
	{
	NSError *error = nil ;
	[self save:&error] ;
	if( error )
		NSLog(@"Could not save MOC: %@" , self) ;
	if( self.parentContext )
		[self.parentContext saveRecursively] ;
	}

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName onlyIDs: (BOOL) onlyIDs
    withPredicate:(id)stringOrPredicate, ...
	{
    NSEntityDescription *entity = [NSEntityDescription
        entityForName:newEntityName inManagedObjectContext:self];

	NSAssert1( entity != nil , @"entity not found for \"%@\"" , newEntityName ) ;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
	[request setIncludesPropertyValues:!onlyIDs] ;

    if (stringOrPredicate)
		{
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
			{
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                arguments:variadicArguments];
            va_end(variadicArguments);
			}
        else
			{
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                @"Second parameter passed to %s is of unexpected class %@",
                sel_getName(_cmd), NSStringFromClass(stringOrPredicate));
            predicate = (NSPredicate *)stringOrPredicate;
			}
        [request setPredicate:predicate];
		}

    NSError *error = nil;
	NSArray *results ;
	@try {
         results = [self executeFetchRequest:request error:&error];
	}
	@catch (NSException *exception) {
		NSLog(@"Exception caught: %@" , exception) ;
	}

    if (error != nil)
		{
		NSLog(@"Could not fetch objects: %@", error) ;
		}

    return [NSSet setWithArray:results];
	}


@end
