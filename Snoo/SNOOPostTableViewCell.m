//
//  SNOOPostTableViewCell.m
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOPostTableViewCell.h"

#define CONTENT_PADDING (20)


@interface SNOOPostTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postLabelTopToSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postLabelBottomToSuperviewContraint;
@property (weak, nonatomic) IBOutlet UIImageView *commentIcon;

@end

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

- (void) awakeFromNib
	{
	[super awakeFromNib] ;
	
	self.commentIcon.image = [self.commentIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ;
	}

#pragma mark - Metrics

+ (CGFloat) heightWithPostText: (NSString *) text
	{
	SNOOPostTableViewCell *exemplar = [SNOOPostTableViewCell exemplar] ;
	
	exemplar.postLabel.text = text ;
	[exemplar.postLabel invalidateIntrinsicContentSize] ;
	[exemplar.postLabel layoutIfNeeded] ;
	[exemplar.containerView layoutIfNeeded] ;
	
	return MIN(exemplar.postLabel.frame.size.height + CONTENT_PADDING * 2.0, exemplar.frame.size.width * (3.0/4.0)) ;
	}

@end
