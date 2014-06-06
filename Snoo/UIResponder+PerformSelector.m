//
//  UIResponder+PerformSelector.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "UIResponder+PerformSelector.h"

@implementation UIResponder (PerformSelector)

- (BOOL)performSelectorViaResponderChain:(SEL)targetSelector withObject:(id)anObject
	{
	UIResponder *nomad = self;
	while (nomad != nil)
		{
		if ([nomad respondsToSelector:targetSelector])
			{
			// Call performSelector:withObject: with targetSelector
			SEL performWithObjectSelector = NSSelectorFromString(@"performSelector:withObject:");
			IMP imp = [nomad methodForSelector:performWithObjectSelector];
			void (*func)(id, SEL, SEL, id) = (void *)imp;
			func(nomad, performWithObjectSelector, targetSelector, anObject) ;
			return YES;
			}
		nomad = [nomad nextResponder];
		}

	return NO;
	}

@end
