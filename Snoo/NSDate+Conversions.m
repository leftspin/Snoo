//
//  NSDate+Conversions.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "NSDate+Conversions.h"

@implementation NSDate (Conversions)

+ (NSDate *) dateFromUTCEpochTimeString: (NSString *) utcEpochTimeString
	{
	
	// http://stackoverflow.com/questions/12261196/how-to-parse-a-utc-epoch-1352716800-to-nsdate
	
	NSString *epochTime = utcEpochTimeString ;
	
	// (Step 1) Convert epoch time to SECONDS since 1970
	NSTimeInterval seconds = [epochTime doubleValue];
//	NSLog (@"Epoch time %@ equates to %qi seconds since 1970", epochTime, (long long) seconds);
	
	// (Step 2) Create NSDate object
	NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
//	NSLog (@"Epoch time %@ equates to UTC %@", epochTime, epochNSDate);
	
	return epochNSDate ;
	}

@end
