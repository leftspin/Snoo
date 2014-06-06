//
//  UIResponder+PerformSelector.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Usually you would use UIApplication's sendAction:to:from:forEvent: to send an action down a responder chain. However, for this to work, from must be an NSResponder in the responder chain. This category allows objects that aren't in the responder chain to perform an action on object in the responder chain. This allows the responder chain to be used to implement a general Command pattern for non-UI objects.

// https://groups.google.com/forum/#!msg/cocoa-unbound/azBfIy3ga3U/1G1A7ZDplYcJ
// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown

#import <UIKit/UIKit.h>

@interface UIResponder (PerformSelector)

// Perform aSelector with anObject as an argument
- (BOOL)performSelectorViaResponderChain:(SEL)aSelector withObject:(id)anObject ;
@end
