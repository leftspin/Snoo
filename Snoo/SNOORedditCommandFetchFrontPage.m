//
//  SNOORedditCommandFetchFrontPage.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOORedditCommandFetchFrontPage.h"
#import "SNOOPagedAccessByURLParameter.h"
#import "NSDictionary+Extract.h"
#import "NSDictionary+Ingest.h"
#import "SNOOFrontPageListingController.h"
#import "SNOOPost.h"
#import "NSManagedObjectContext+Convenience.h"

@interface SNOORedditCommandFetchFrontPage ()
@property( nonatomic, strong ) NSManagedObjectContext *childMOC ;
@end

@implementation SNOORedditCommandFetchFrontPage

#pragma mark - Instance

- (instancetype) init
	{
	self = [super init] ;
	if( self )
		{
		// http://www.cocoanetics.com/2012/07/multi-context-coredata/
		NSManagedObjectContext *mainMOC = [UIApplication snooAppDelegate].managedObjectContext ;
		self.childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] ;
		self.childMOC.parentContext = mainMOC ;
		}
	return self ;
	}

#pragma mark - SNOORedditCommandFetchFrontPage

- (void) performFromFirstPage
	{
	if( self.isPerforming )
		return ;
	
	self.pager = nil ;
	
	// Clear out all objects that match the UI context
	[self.childMOC performBlock:^
		{
		NSSet *objectsToDelete = [self.childMOC fetchObjectsForEntityName:SNOO_POST_ENTITY_NAME onlyIDs:YES withPredicate:@"ui_context == %@" , SNOO_UI_CONTEXT_FRONT_PAGE] ;
		
		[objectsToDelete enumerateObjectsUsingBlock:^(SNOOPost *post, BOOL *stop)
			{
			[self.childMOC deleteObject:post] ;
			}] ;
		
		[self.childMOC saveRecursively] ;
		}] ;
	
	// Do eeeet
	[self perform] ;
	}

#pragma mark - SNOOURLRepresentable

- (NSURLRequest *) URLRequestRepresentationWithRootURL: (NSURL *) rootURL
	{
	NSParameterAssert(rootURL) ;
	
	NSURL *relativeURL = [NSURL URLWithString:@".json" relativeToURL:rootURL] ;
	NSURLRequest *endpointRequest = [NSURLRequest requestWithURL:relativeURL] ;
	
	// Rewrite the request if we have a pager
	if( self.pager )
		endpointRequest = [self.pager pagedURLRequestFromEndpointURLRequest:endpointRequest] ;
	
	return endpointRequest ;
	}

#warning test
- (BOOL) handleResponseObject: (id) responseObject error: (NSError **) pointerToError ;
	{
	NSParameterAssert(pointerToError) ;
	*pointerToError = nil ; // Safety
	
	// See if it's a dictionary
	if( ![responseObject isKindOfClass:[NSDictionary class]] )
		{
		*pointerToError = [NSError errorWithDomain:SNOOREDDITCOMMAND_FETCHFRONTPAGE_ERROR_DOMAIN code:xkSNOORedditCommandFetchFrontPageErrorUnexpectedDataType userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expected an dictionary but instead got: %@", responseObject]}] ;
		return NO ;
		}
	NSDictionary *responseDict = (NSDictionary *) responseObject ;
	
	// Record any paging information if it's there
	NSString *nextPageToken = [responseDict listingNextPageTokenWithError:pointerToError] ;
	if( *pointerToError )
		return NO ;
	
	self.pager = nextPageToken ? [SNOOPagedAccessByURLParameter pagedAcccessByURLParameterWithNextPageToken:nextPageToken] : nil ;

	// Ingest the Listing into SNOO_UI_CONTEXT_FRONT_PAGE
	[responseDict ingestAsListingIntoUIContext:SNOO_UI_CONTEXT_FRONT_PAGE usingContext:self.childMOC error:pointerToError] ;
	if( *pointerToError )
		return NO ;
	
	return YES ;
	}

@end
