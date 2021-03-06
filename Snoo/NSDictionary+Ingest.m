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
#import "_SNOOPost.h"
#import "NSDate+Conversions.h"
#import "NSString+Prettify.h"

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

- (BOOL) mapAsListingObjectIntoPost: (_SNOOPost *) post error: (NSError **) pointerToError
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
	post.title = [SAFESTRING([self valueForKeyPath:@"data.title"]) prettyfy] ;
	if( post.title.length == 0 )
		post.title = @"[Unspecified Title]" ;
	post.is_self = [self valueForKeyPath:@"data.is_self"] ;
	post.redditID = SAFESTRING([self valueForKeyPath:@"data.id"]) ;
	post.selftext = SAFESTRING([self valueForKeyPath:@"data.selftext"]) ;

	NSString *linkURLString = SAFESTRING([self valueForKeyPath:@"data.url"]) ;
	post.url = [linkURLString rangeOfString:@"http"].location == 0 ? linkURLString : nil ;
	
	post.created_date = [NSDate dateFromUTCEpochTime:[self valueForKeyPath:@"data.created_utc"]] ;
	post.score = [self valueForKeyPath:@"data.score"] ;
	post.num_comments = [self valueForKeyPath:@"data.num_comments"] ;

	NSString *thumbnailURLString = SAFESTRING([self valueForKeyPath:@"data.thumbnail"]) ;
	post.thumbnail = [thumbnailURLString rangeOfString:@"http"].location == 0 ? thumbnailURLString : nil ;
	
	return YES ;
	}
@end
