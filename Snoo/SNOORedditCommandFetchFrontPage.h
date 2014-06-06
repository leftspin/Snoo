//
//  SNOORedditCommandFetchFrontPage.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  A command to fetch the front page of Reddit

#import "SNOORedditCommand.h"
#import "SNOOURLRepresentable.h"
#import "SNOOPagedAccess.h"

#define SNOOREDDITCOMMAND_FETCHFRONTPAGE_ERROR_DOMAIN @"SNOOREDDITCOMMAND_FETCHFRONTPAGE_ERROR_DOMAIN"

typedef enum : NSUInteger
	{
	xkSNOORedditCommandFetchFrontPageErrorUnexpectedDataType ,
	xkSNOORedditCommandFetchFrontPageErrorUnrecognizedStructure ,
	xkSNOORedditCommandFetchFrontPageErrorCorruptedData ,
	} xeSNOORedditCommandFetchFrontPageError ;

@interface SNOORedditCommandFetchFrontPage : SNOORedditCommand <SNOOURLRepresentable>

@property( nonatomic, readonly ) id <SNOOPagedAccess> pager ;

// Each perform of the receiver will fetch subsequent pages. Calling this method on the receiver will reset it so it fetches from the top. Calling this will also invalidate
- (void) performFromFirstPage ;

@end
