//
//  SNOOCounters.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Provides auto-incrementing counters. E.g., used to preserve sort orders from a service. This is likely to be used in a multithreaded context, so all instance methods are re-entrant.

@import Foundation ;

@interface SNOOCounters : NSObject

// A singleton if you wish to persist a count for the life of the app
+ (instancetype) sharedCounters ;

- (void) resetCounterWithName: (NSString *) name ;
- (NSUInteger) nextValueForCounterWithName: (NSString *) name ;

@end
