//
//  NSDictionary+Recognize.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "NSDictionary+Recognize.h"

@implementation NSDictionary (Recognize)

- (xeRedditStructureType) structureType
	{
	return [SNOORedditConstants structureTypeForID:[self valueForKey:@"kind"]] ;
	}
@end
