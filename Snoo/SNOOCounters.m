//
//  SNOOCounters.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOCounters.h"

@interface SNOOCounters ()
@property( nonatomic, strong ) NSMutableDictionary *counters ;
@end

@implementation SNOOCounters

#pragma mark - Instance

+ (instancetype) sharedCounters
	{
	static SNOOCounters *counters ;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
		{
		counters = [SNOOCounters new] ;
		});
	return counters ;
	}

- (instancetype) init
	{
	self = [super init] ;
	if( self )
		{
		self.counters = [NSMutableDictionary dictionary] ;
		}
	return self ;
	}

#pragma mark - SNOOCounters

- (void) resetCounterWithName: (NSString *) name
	{
	NSParameterAssert(name) ;
	NSAssert( self.counters , @"self.counters uninitialized" ) ;
	
	@synchronized(self.counters)
		{
		[self.counters removeObjectForKey:name] ;
		}
	}

- (NSUInteger) nextValueForCounterWithName: (NSString *) name
	{
	NSParameterAssert(name) ;
	NSAssert( self.counters , @"self.counters uninitialized" ) ;
	
	NSNumber *currentValue = nil ;
	@synchronized(self.counters)
		{
		currentValue = [self.counters objectForKey:name] ;
		if( !currentValue )
			currentValue = @0 ;
		
		NSNumber *nextValue = @(currentValue.unsignedIntegerValue + 1) ;
		[self.counters setObject:nextValue forKey:name] ;
		}
	
	return currentValue.unsignedIntegerValue ;
	}

@end
