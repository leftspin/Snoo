//
//  NSDictionary+Extract.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Logic to extract substructures from a Reddit JSON encoded as a dictionary

@import Foundation ;

#define REDDIT_EXTRACT_ERROR_DOMAIN @"REDDIT_EXTRACT_ERROR_DOMAIN"

typedef enum : NSInteger
	{
	xkRedditExtractionErrorUnexpectedStructureType ,
	xkRedditExtractionErrorCorruptedStructure ,
	} xeRedditExtractionError ;

@interface NSDictionary (Extract)

/** Listings **/

// Treat self as a Listing and return its children, or nil if there are no children. This call is successful if error is nil. If an error is returned the return value is unspecified.
- (NSArray *) listingChildrenWithError: (NSError **) error ;

// Treat self as a Listing and return its next page token, or nil if there are no more pages. This call is successful if error is nil. If an error is returned the return value is unspecified.
- (NSString *) listingNextPageTokenWithError: (NSError **) error ;
@end
