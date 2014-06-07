//
//  NSArray+Ingest.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "NSArray+Ingest.h"
#import "NSDictionary+Recognize.h"
#import "NSManagedObjectContext+Convenience.h"
#import "SNOOPost.h"
#import "NSDictionary+Ingest.h"

@implementation NSArray (Ingest)

- (BOOL) ingestAsListingObjectsIntoUIContext: (NSString *) uiContext usingContext: (NSManagedObjectContext *) moc error: (NSError **) pointerToError
	{
	NSParameterAssert(moc) ;
	NSParameterAssert(uiContext) ;
	NSParameterAssert(pointerToError) ;
	NSAssert( uiContext.length > 0 , @"uiContext should be more than 0 characters long" ) ; // sanity check
	*pointerToError = nil ; // Safety
	
	// Ingest objects asynchronously
	[moc performBlock:^
		{
		
		
		// As items are ingested, they are assigned a increasing value for service_order so that they can be sorted later. The current index is the number of objects with uiContext
		// http://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
		NSUInteger startingIndex = 0 ;
		NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
		request.predicate = [NSPredicate predicateWithFormat:@"ui_context == %@" , uiContext] ;
		[request setEntity:[NSEntityDescription entityForName:SNOO_POST_ENTITY_NAME inManagedObjectContext:moc]] ;
		request.includesSubentities = NO ;
		NSError *countError = nil ;
		NSUInteger count = [moc countForFetchRequest:request error:&countError] ;
		if( count == NSNotFound )
			count = 0 ;
		startingIndex = count ;
		
		// Ingest each object
		[self enumerateObjectsUsingBlock:^(NSDictionary *listingObject, NSUInteger idx, BOOL *stop)
			{
			// Make sure it's a dictionary
			if( ![listingObject isKindOfClass:[NSDictionary class]] )
				{
				NSLog(@"Unexpected class type encountered while ingesting front page posts: %@" , [listingObject class]) ;
				}
			else
				{
				SNOOPost *post = [NSEntityDescription insertNewObjectForEntityForName:SNOO_POST_ENTITY_NAME inManagedObjectContext:moc] ;
				if( !post )
					{
					NSLog(@"Could not create a new SNOOPost") ;
					}
				else
					{
					NSError *mapError = nil ;
					
					// Give this post a service_order so that it can be sorted later by the order fetched from the server
					post.service_order = @(startingIndex + idx) ;
					
					// Give this post a ui_context so that different screens only pull the proper objects
					post.ui_context = uiContext ;
					
					// Perform the mapping
					if( ![listingObject mapAsListingObjectIntoPost:post error:&mapError] )
						{
						NSLog(@"Could not map to post: %@" , listingObject) ;
						}
					} // if post
				} // if descriptor is a dictionary
			}] ; // each post
		
				
		// Sync all MOCs up the chain
		[moc saveRecursively] ;
		
		
		}] ; // Ingest objects asynchronously
	
	return YES ;
	}

@end
