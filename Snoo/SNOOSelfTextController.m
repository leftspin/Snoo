//
//  SNOOSelfTextController.m
//  Snoo
//
//  Created by Mike Manzano on 6/8/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOSelfTextController.h"

@interface SNOOSelfTextController ()

@end

@implementation SNOOSelfTextController

#pragma mark - View lifecycle

- (void) viewDidLoad
	{
	[super viewDidLoad] ;
	
	[self.navigationController setNavigationBarHidden:NO animated:YES] ;
	
	[self.textView setTextContainerInset:UIEdgeInsetsMake(20, 20, 20, 20)] ;
	
	self.textView.text = self.initialText ;
	}
@end
