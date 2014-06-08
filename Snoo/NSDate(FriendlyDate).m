//
//  NSDate(FriendlyDate).m
//  Newsie
//
//  Created by Mike Manzano on 5/20/09.
//  Copyright 2009 IVM. All rights reserved.
//

#import "NSDate(FriendlyDate).h"
#import "SORelativeDateTransformer.h"

@implementation NSDate (FriendlyDate)

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
	{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
	
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
	
    return YES;
	}

+ (NSString *) friendlyDateWithJSONDate: (unsigned long long) jsonDate
	{
	return [[NSDate dateWithJSONDate:jsonDate] friendlyDateWithEndDate:nil] ;
	}

+ (NSDate *) dateWithJSONDate: (unsigned long long) jsonDate
	{
	NSString *stringJSONDate = [NSString stringWithFormat:@"%llu", jsonDate] ;
	if( stringJSONDate.length > 10 )
		stringJSONDate = [NSString stringWithFormat:@"%llu", jsonDate / 1000] ;
	return [NSDate dateWithTimeIntervalSince1970:stringJSONDate.integerValue] ;
	}

// https://gist.github.com/1135412	
- (NSString*) JSON
	{
	long long date = [self timeIntervalSince1970] * 1000;
	return [NSString stringWithFormat:@"%qi", date] ;
	}
	
- (NSString *) friendlyDateWithEndDate: (NSDate *) endDate
	{
	static SORelativeDateTransformer *transformer ;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
		{
		transformer = [[SORelativeDateTransformer alloc] init] ;
		}) ;
	NSString *theFriendlyDate = [transformer transformedValue:self] ;
	
	if( endDate )
		{
		NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0] ;
		if( [NSDate date:now isBetweenDate:self andDate:endDate] )
			{
			theFriendlyDate = [NSString stringWithFormat:@"ending %@" , [transformer transformedValue:endDate]] ;
			}
		}
	
	return theFriendlyDate ;
	}

- (NSString *) abbreviatedFriendlyDate
	{
	const int SECOND = 1;
	const int MINUTE = 60 * SECOND;
	const int HOUR = 60 * MINUTE;
	const int DAY = 24 * HOUR;
	const int MONTH = 30 * DAY;

	NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self]; // diff = 3600.0

	if (delta < 0)
		{
		return @"not yet";
		}
	if (delta < 1 * MINUTE)
		{
		return [NSString stringWithFormat:@"%0.0fs", floorf(delta)] ;
		}
	if (delta < 2 * MINUTE)
		{
		return @"1m";
		}
	if (delta < 45 * MINUTE)
		{
		return [NSString stringWithFormat:@"%0.0fm", floorf(delta / MINUTE)] ;
		}
	if (delta < 90 * MINUTE)
		{
		return @"1h";
		}
	if (delta < 24 * HOUR)
		{
		return [NSString stringWithFormat:@"%0.0fh", floorf(delta / HOUR)] ;
		}
	if (delta < 48 * HOUR)
		{
		return @"1d";
		}
	if (delta < 30 * DAY)
		{
		return [NSString stringWithFormat:@"%0.0fd", floorf(delta / DAY)] ;
		}
	if (delta < 12 * MONTH)
		{
		int months = delta / MONTH ;
		return months <= 1 ? @"1mo" : [NSString stringWithFormat:@"%0.0fmo", floorf(delta / MONTH)] ;
		}
	else
		{
		int years = floorf(delta/(DAY*365)) ;
		return years <= 1 ? @"1y" : [NSString stringWithFormat:@"%dy", years] ;
		}
	}
@end
