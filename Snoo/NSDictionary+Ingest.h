//
//  NSDictionary+Ingest.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Ingest items in a dictionary into objects native to Snoo. Each method here ingests the objects into a particular user interface context.

@import Foundation ;
@import CoreData ;

@class SNOOPost ;

#define DICTIONARY_INGEST_ERROR_DOMAIN @"DICTIONARY_INGEST_ERROR_DOMAIN"
typedef enum : NSUInteger
	{
	xkDictionaryIngestErrorInvalidStructureType
	} xeDictionaryIngestError ;


@interface NSDictionary (Ingest)

// Ingests objects in the receiver to the front page of the app. Returns YES on success. If it returns NO, error will contain an error. If it returns YES, the contents of error will be undefined.
- (BOOL) ingestAsListingIntoUIContext: (NSString *) uiContext usingContext: (NSManagedObjectContext *) moc error: (NSError **) pointerToError ;

// Maps a Listing object into a SNOOPost. Returns YES if successful. If not successful, returns NO and sets pointerToError. pointerToError is undefined if successful.
- (BOOL) mapAsListingObjectIntoPost: (SNOOPost *) post error: (NSError **) pointerToError ;
@end
