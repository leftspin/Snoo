//
//  SNOORedditService.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  A class for interacting with the Reddit Service

@import UIKit ;
#import "SNOORedditCommand.h"

// Errors
#define SNOOREDDITSERVICE_ERROR_DOMAIN @"SNOOREDDITSERVICE_ERROR_DOMAIN"
typedef enum : NSUInteger
	{
	xkSNOORedditServiceErrorUnknownError ,
	xkSNOORedditServiceErrorUnknownCommand ,
	xkSNOORedditServiceErrorMissingURLRequest ,
	} xeSNOORedditServiceError ;

@interface SNOORedditService : UIResponder

// The entry point for all SNOORedditCommands
- (void) handleRedditCommand: (SNOORedditCommand *) redditCommand ;

@end
