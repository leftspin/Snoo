//
//  SNOOFrontPageListingController.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOFrontPageListingController.h"
#import "SNOORedditCommandFetchFrontPage.h"
#import "SNOOPagedAccess.h"

@interface SNOOFrontPageListingController ()
@property( nonatomic, strong ) SNOORedditCommandFetchFrontPage *fetchCommand ;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fetchNextPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshFromTopButton;
@end

@implementation SNOOFrontPageListingController

#pragma mark - View lifecycle

- (void) viewDidLoad
	{
	[super viewDidLoad] ;
	
	__weak SNOOFrontPageListingController *weakSelf = self ;
	
	self.fetchNextPageButton.enabled = NO ;
	
	self.fetchCommand = [SNOORedditCommandFetchFrontPage new] ;
	self.fetchCommand.finishedBlock = ^(NSError *error)
		{
		__strong SNOOFrontPageListingController *strongSelf = weakSelf ;

		strongSelf.fetchNextPageButton.enabled = strongSelf.fetchCommand.pager.hasNextPage ;
		strongSelf.refreshFromTopButton.enabled = YES ;

		if( error )
			NSLog(@"%@", error.localizedDescription) ;
		else
			NSLog(@"Command successful!") ;
		} ;
	}

#pragma mark - Actions

- (IBAction)refreshTapped:(UIBarButtonItem *)sender
	{
	self.fetchNextPageButton.enabled = NO ;
	self.refreshFromTopButton.enabled = NO ;
	[self.fetchCommand performFromFirstPage] ;
	}

- (IBAction)nextPageTapped:(UIBarButtonItem *)sender
	{
	self.fetchNextPageButton.enabled = NO ;
	self.refreshFromTopButton.enabled = NO ;
	[self.fetchCommand perform] ;
	}

@end
