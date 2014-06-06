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

@interface SNOORedditCommandFetchFrontPage ()
@property( nonatomic, strong ) id <SNOOPagedAccess> pager ;
@end

@implementation SNOORedditCommandFetchFrontPage

- (void) performFromFirstPage
	{
	if( self.isPerforming )
		return ;
	
	self.pager = nil ;
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

	// Get children
	NSArray *items = [responseDict listingChildrenWithError:pointerToError] ;
	if( *pointerToError )
		return NO ;
	
	return YES ;
	}

@end
