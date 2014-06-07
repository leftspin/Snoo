//
//  SNOOPagedAccess.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  An object that represents a position in paged data on a remote service

@import Foundation ;

@protocol SNOOPagedAccess <NSObject, NSCoding>

// Is YES if there is another page, NO otherwise
@property( nonatomic, readonly ) BOOL hasNextPage ;

// Returns endpointURLRequest modified to fetch data at the current page in the data represented by an endpoint.
- (NSURLRequest *) pagedURLRequestFromEndpointURLRequest: (NSURLRequest *) endpointURLRequest ;

@end
