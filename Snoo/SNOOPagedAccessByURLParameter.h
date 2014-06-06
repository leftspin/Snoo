//
//  SNOOPagedAccessByResultsKeyPath.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  An implementation of SNOOURLPagedAccess that appends page information as URL parameters

@import Foundation ;
#import "SNOOPagedAccess.h"

@interface SNOOPagedAccessByURLParameter : NSObject <SNOOPagedAccess>

// The token that will be added to the URL
@property( nonatomic, strong ) NSString *nextPageToken ;

+ (instancetype) pagedAcccessByURLParameterWithNextPageToken: (NSString *) nextPageToken ;

@end
