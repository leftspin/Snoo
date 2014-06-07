//
//  NSDictionary+Ingest.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "NSDictionary+Ingest.h"
#import "NSDictionary+Extract.h"
#import "NSArray+Ingest.h"
#import "NSDictionary+Recognize.h"
#import "SNOOPost.h"
#import "NSDate+Conversions.h"
#import "SNOOCounters.h"

@implementation NSDictionary (Ingest)

- (BOOL) ingestAsListingIntoUIContext: (NSString *) uiContext usingContext: (NSManagedObjectContext *) moc error: (NSError **) pointerToError
	{
	NSParameterAssert(moc) ;
	NSParameterAssert(uiContext) ;
	NSAssert( uiContext.length > 0 , @"uiContext should be more than 0 characters long" ) ; // sanity check
	NSParameterAssert(pointerToError) ;
	*pointerToError = nil ; // Safety
	
	// Get the children
	NSArray *items = [self listingChildrenWithError:pointerToError] ;
	if( *pointerToError )
		return NO ;
	
	// Ingest them
	[items ingestAsListingObjectsIntoUIContext: uiContext usingContext:moc error:pointerToError] ;
	if( *pointerToError )
		return NO ;

	return YES ;
	}

- (BOOL) mapAsListingObjectIntoPost: (SNOOPost *) post error: (NSError **) pointerToError
	{
	NSParameterAssert(post) ;
	NSParameterAssert(pointerToError) ;
	*pointerToError = nil ; // Safety
	
	// Make sure self is something we can map to a post
	if( ![self isPost] )
		{
		*pointerToError = [NSError errorWithDomain:DICTIONARY_INGEST_ERROR_DOMAIN code:xkDictionaryIngestErrorInvalidStructureType userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Can't map this to a Post: %@", self]}] ;
		return NO ;
		}
		
	post.kind = SAFESTRING(self[@"kind"]) ;
	post.title = SAFESTRING([self valueForKeyPath:@"data.title"]) ;
	post.is_self = [self valueForKeyPath:@"data.is_self"] ;
	post.redditID = SAFESTRING([self valueForKeyPath:@"data.id"]) ;
	post.selftext = SAFESTRING([self valueForKeyPath:@"data.selftext"]) ;
	post.url = SAFESTRING([self valueForKeyPath:@"data.url"]) ;

	NSString *utcEpochTimeString = SAFESTRING([self valueForKeyPath:@"data.created_utc"]) ;
	if( utcEpochTimeString.length > 0 )
		post.created_date = [NSDate dateFromUTCEpochTimeString:utcEpochTimeString] ;

	return YES ;
	}
@end
