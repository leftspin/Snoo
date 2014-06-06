//
//  SNOORedditCommand.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOORedditCommand.h"
#import "UIResponder+PerformSelector.h"

@interface SNOORedditCommand ()
@property( nonatomic, assign ) BOOL isPerforming ;
@end

@implementation SNOORedditCommand

#pragma mark - SNOORedditCommand

- (void) perform
	{
	if( self.isPerforming )
		return ;
	
	// Send this command down the responder chain; this decouples SNOORedditCommands from any specific fulfillment, but normally it will end up being fulfilled by a SNOORedditService somewhere down the responder chain
	SEL handleRedditCommandSelector = sel_registerName("handleRedditCommand:") ;
	
	self.isPerforming = YES ;
	if( ![[UIApplication sharedApplication] performSelectorViaResponderChain:handleRedditCommandSelector withObject:self] )
		{
		self.isPerforming = NO ;
		NSLog(@"handleRedditCommand: not found in the responder chain") ;
		}
	}

- (void) cancel
	{
	if( !self.isPerforming )
		return ;
	
	if( self.cancelBlock ) self.cancelBlock() ;
	self.isPerforming = NO ;
	}

- (void) finishWithError: (NSError *) error ;
	{
	self.isPerforming = NO ;
	if( self.finishedBlock ) self.finishedBlock( error ) ;
	}
@end
