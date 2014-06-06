//
//  SNOORedditConstants.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  Contains smarts about Reddit constants
//  Ref: http://www.reddit.com/dev/api

@import Foundation ;

typedef enum : NSInteger
	{
	xkRedditStructureTypeUnknown = -1 ,
	xkRedditStructureTypeComment = 1 ,
	xkRedditStructureTypeAccount = 2,
	xkRedditStructureTypeLink = 3 ,
	xkRedditStructureTypeMessage = 4 ,
	xkRedditStructureTypeSubreddit = 5 ,
	xkRedditStructureTypeAward = 6 ,
	xkRedditStructureTypePromoCampaign = 8 ,
	
	xkRedditStructureTypeListing = 1000 ,
	} xeRedditStructureType ;

#define REDDIT_STRUCTURE_ID_COMMENT @"t1"
#define REDDIT_STRUCTURE_ID_ACCOUNT @"t2"
#define REDDIT_STRUCTURE_ID_LINK @"t3"
#define REDDIT_STRUCTURE_ID_MESSAGE @"t4"
#define REDDIT_STRUCTURE_ID_SUBREDDIT @"t5"
#define REDDIT_STRUCTURE_ID_AWARD @"t6"
#define REDDIT_STRUCTURE_ID_PROMOCAMPAIGN @"t8"

#define REDDIT_STRUCTURE_ID_LISTING @"Listing"

@interface SNOORedditConstants : NSObject

// Return the prefix for structureType, or nil if it's not recognized
+ (NSString *) IDForStructureType: (xeRedditStructureType) structureType ;

// Return the posting type given a prefix string, or xkRedditStructureTypeUnknown if it's not recognized
+ (xeRedditStructureType) structureTypeForID: (NSString *) prefix ;

@end
