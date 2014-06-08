//
//  SNOOPostTableViewCell.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOPostTableViewCell.h"

#define CONTENT_PADDING (20)

@implementation SNOOPostTableViewCell

#pragma mark - Instance

+ (instancetype) postTableViewCell
	{
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SNOOPostTableViewCell" owner:nil options:nil] ;
	SNOOPostTableViewCell *cell = nibObjects[0] ;
	NSAssert1([cell isKindOfClass:[SNOOPostTableViewCell class]], @"cell is not a SNOOPostTableViewCell but a %@", [cell class]) ;
	
	return cell ;
	}

+ (instancetype) exemplar
	{
	static SNOOPostTableViewCell *cell ;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
		{
		cell = [SNOOPostTableViewCell postTableViewCell] ;
		}) ;
	
	return cell ;
	}

#pragma mark - Metrics

+ (CGFloat) heightWithPostText: (NSString *) text
	{
	SNOOPostTableViewCell *exemplar = [SNOOPostTableViewCell exemplar] ;
	
	CGRect frame = exemplar.frame ;
	frame.size.height = CGFLOAT_MAX ;
	exemplar.postLabel.text = text ;
	[exemplar.postLabel invalidateIntrinsicContentSize] ;
	[exemplar.postLabel layoutIfNeeded] ;
	
	return exemplar.postLabel.frame.size.height + CONTENT_PADDING * 2.0 ;
	}

@end
