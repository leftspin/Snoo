//
//  SNOORedditConstants.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOORedditConstants.h"

@implementation SNOORedditConstants

+ (NSString *) IDForStructureType: (xeRedditStructureType) structureType
	{
	NSString *result = nil ;
	
	switch (structureType)
		{
		case xkRedditStructureTypeComment :
			result = REDDIT_STRUCTURE_ID_COMMENT ;
			break ;
		case xkRedditStructureTypeAccount :
			result = REDDIT_STRUCTURE_ID_ACCOUNT ;
			break ;
		case xkRedditStructureTypeLink :
			result = REDDIT_STRUCTURE_ID_LINK ;
			break ;
		case xkRedditStructureTypeMessage :
			result = REDDIT_STRUCTURE_ID_MESSAGE ;
			break ;
		case xkRedditStructureTypeSubreddit :
			result = REDDIT_STRUCTURE_ID_SUBREDDIT ;
			break ;
		case xkRedditStructureTypeAward :
			result = REDDIT_STRUCTURE_ID_AWARD ;
			break ;
		case xkRedditStructureTypePromoCampaign :
			result = REDDIT_STRUCTURE_ID_PROMOCAMPAIGN ;
			break ;
			
		case xkRedditStructureTypeListing :
			result = REDDIT_STRUCTURE_ID_LISTING ;
			break ;
			
		default:
			break;
	}
	
	return result ;
	}

+ (xeRedditStructureType) structureTypeForID: (NSString *) prefix
	{
	xeRedditStructureType result = xkRedditStructureTypeUnknown ;
	
	if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_COMMENT])
		{
		result = xkRedditStructureTypeComment ;
		}
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_ACCOUNT])
		{
		result = xkRedditStructureTypeAccount ;
		}
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_LINK])
		{
		result = xkRedditStructureTypeLink ;
		}
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_MESSAGE])
		{
		result = xkRedditStructureTypeMessage ;
		}
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_SUBREDDIT])
		{
		result = xkRedditStructureTypeSubreddit ;
		}
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_AWARD])
		{
		result = xkRedditStructureTypeAward ;
		}
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_PROMOCAMPAIGN])
		{
		result = xkRedditStructureTypePromoCampaign ;
		}
	
	else if( [prefix isEqualToString:REDDIT_STRUCTURE_ID_LISTING])
		{
		result = xkRedditStructureTypeListing ;
		}
	
	return result ;
	}

@end
