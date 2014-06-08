//
//  NSString+Prettify.m
//  Snoo
//
//  Created by Mike Manzano on 6/8/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "NSString+Prettify.h"

@implementation NSString (Prettify)

- (NSString *) prettyfy
	{
	NSString *workingString = [self stringByReplacingOccurrencesOfString:@"--" withString:@"—"] ;
	workingString = [workingString stringByReplacingOccurrencesOfString:@"[NSFW]" withString:@"😮NSFW"] ;
	workingString = [workingString stringByReplacingOccurrencesOfString:@"..." withString:@"…"] ;
	return workingString ;
	}

@end
