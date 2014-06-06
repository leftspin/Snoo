//
//  SNOORedditCommand.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  An abstract Reddit command for use with a SNOORedditService.

@import Foundation ;

// A command that executes by sending itself up the responder chain to a party that can handle it
@interface SNOORedditCommand : NSObject

// When the command finishes, this block is called. A successful perform returns nil for error, and an NSError otherwise
@property( nonatomic, copy ) void (^finishedBlock)(NSError *error) ;

// Return YES if this command is currently performing
#warning test
@property( nonatomic, readonly ) BOOL isPerforming ;

// Perform the receiver, but only if it isn't currently being performed.
- (void) perform ;

// Cancel the receiver. This is safe to call even if -peform hasn't been called. In that case it does nothing.
- (void) cancel ;


/***** Nothing below this line is user servicable *****/

// After the receiver has been sent down the responder chain and handled, this property will be assigned a block that can be called to cancel the receiver. It may be nil if the receiver can't be cancelled. If you set this block yourself, it will simply get overwritten by the handler. Do not call this yourself, instead use -cancel so that the command can be reset to be used again
@property( nonatomic, copy ) void (^cancelBlock)(void) ;

// This is called by the service when it considers itself finished. It calls any user-supplied finishedBlock and sets isPerforming to NO
- (void) finishWithError: (NSError *) error ;

@end
