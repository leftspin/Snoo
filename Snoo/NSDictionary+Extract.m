//
//  NSDictionary+Extract.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Tools to extract key data from a Reddit JSON structure encoded as a dictionary

#import "NSDictionary+Extract.h"
#import "NSDictionary+Recognize.h"

@implementation NSDictionary (Extract)

#warning test
- (NSArray *) listingChildrenWithError: (NSError **) pointerToError
	{
	NSParameterAssert(pointerToError) ;
	
	// If this isn't a listing, we don't know WHAT it is, make like a bakery truck and haul buns
	if( [self structureType] != xkRedditStructureTypeListing )
		{
		*pointerToError = [NSError errorWithDomain:REDDIT_EXTRACT_ERROR_DOMAIN code:xkRedditExtractionErrorUnexpectedStructureType userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expected a Listing but got this: %@", self]}] ;
		return nil ;
		}
	
	// See if the key path "data.children" exists
	id possiblyItems = [self valueForKeyPath:@"data.children"] ;

	// Make sure possiblyItems is an array
	if( ![possiblyItems isKindOfClass:[NSArray class]] )
		{
		*pointerToError = [NSError errorWithDomain:REDDIT_EXTRACT_ERROR_DOMAIN code:xkRedditExtractionErrorCorruptedStructure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expecting an array of items, instead got %@", possiblyItems]}] ;
		return nil ;
		}
	
#warning this is an assumption:
	return possiblyItems ; // This can't be nil, should at least return an empty array
	}

#warning test
- (NSString *) listingNextPageTokenWithError: (NSError **) pointerToError
	{
	NSParameterAssert(pointerToError) ;
	
	// If this isn't a listing, we don't know WHAT it is, make like a tree and leave
	if( [self structureType] != xkRedditStructureTypeListing )
		{
		*pointerToError = [NSError errorWithDomain:REDDIT_EXTRACT_ERROR_DOMAIN code:xkRedditExtractionErrorUnexpectedStructureType userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expected a Listing but got this: %@", self]}] ;
		return nil ;
		}

	id possiblePageState = [self valueForKeyPath:@"data.after"] ;

	// If it returned something, and that something is a string (it's not an error if possiblePageState is nil)
	if( possiblePageState && ![possiblePageState isKindOfClass:[NSString class]] )
		{
		*pointerToError = [NSError errorWithDomain:REDDIT_EXTRACT_ERROR_DOMAIN code:xkRedditExtractionErrorCorruptedStructure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expecting a string, instead got %@", possiblePageState]}] ;
		return nil ;
		}
	
	return possiblePageState ; // nil is a valid return
	}
@end
