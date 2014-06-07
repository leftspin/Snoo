//
//  NSArray+Ingest.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Ingest items in an array into objects native to Snoo. Each method here ingests the objects into a particular user interface context.

@import Foundation ;
@import CoreData ;

@interface NSArray (Ingest)

// Ingests objects in the receiver to the front page of the app. Returns YES on success. If it returns NO, error will contain an error. If it returns YES, the contents of error will be undefined.
- (BOOL) ingestAsListingObjectsIntoUIContext: (NSString *) uiContext usingContext: (NSManagedObjectContext *) moc error: (NSError **) error ;

@end
