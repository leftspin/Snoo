//
//  NSManagedObjectContext+Convenience.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

@import CoreData ;

@interface NSManagedObjectContext (Convenience)

// Recursively saves the receiver and all ancestors
- (void) saveRecursively ;

// http://cocoawithlove.com/2008/03/core-data-one-line-fetch.html
// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName onlyIDs: (BOOL) onlyIDs withPredicate:(id)stringOrPredicate, ... ;

@end
