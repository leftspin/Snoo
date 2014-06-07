//
//  SNOOPagedAccessByResultsKeyPath.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOPagedAccessByURLParameter.h"
#import "NSURL+Queries.h"

@implementation SNOOPagedAccessByURLParameter

#pragma mark - Properties

@dynamic hasNextPage ;
- (BOOL) hasNextPage
	{
	return self.nextPageToken.length > 0 ;
	}

#pragma mark - Instance

+ (instancetype) pagedAcccessByURLParameterWithNextPageToken: (NSString *) nextPageToken
	{
	SNOOPagedAccessByURLParameter *newInstance = [SNOOPagedAccessByURLParameter new] ;
	newInstance.nextPageToken = nextPageToken ;
	return newInstance ;
	}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
	{
	self = [super init] ;
	if( self )
		{
		self.nextPageToken = [aDecoder decodeObjectForKey:@"nextPageToken"] ;
		}
	return self ;
	}

#pragma mark - SNOOPagedAccess

- (NSURLRequest *) pagedURLRequestFromEndpointURLRequest: (NSURLRequest *) endpointURLRequest
	{
	if( [self.nextPageToken length] == 0 )
		return endpointURLRequest ;
	
	NSMutableURLRequest *modifiedRequest = [endpointURLRequest mutableCopy] ;
	modifiedRequest.URL = [endpointURLRequest.URL URLByAppendingQueryString:[NSString stringWithFormat:@"after=%@", self.nextPageToken]] ;
	
	return modifiedRequest ;
	}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)aCoder
	{
	[aCoder encodeObject:self.nextPageToken forKey:@"nextPageToken"] ;
	}

@end
