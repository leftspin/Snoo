//
//  SNOORedditService.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOORedditService.h"
#import "SNOOURLRepresentable.h"
#import <AFNetworking/AFNetworking.h>

// Reddit root URL
#define REDDIT_ROOT @"http://www.reddit.com/"

@interface SNOORedditService ()
@property( nonatomic, strong ) NSOperationQueue *operationQueue ;
@end

@implementation SNOORedditService

#pragma mark - Instance

- (instancetype) init
	{
	self = [super init] ;
	if( self )
		{
		self.operationQueue = [NSOperationQueue new] ;
		}
	return self ;
	}

- (void) dealloc
	{
	[self.operationQueue cancelAllOperations] ;
	}

#pragma mark - Handlers

- (void) handleRedditCommand: (SNOORedditCommand *) command
	{
	NSParameterAssert([command isKindOfClass:[SNOORedditCommand class]]) ;
	
	NSLog(@"Handling: %@" , command) ;
	
	if( [command conformsToProtocol:@protocol(SNOOURLRepresentable)])
		{
		[self handleNetworkingCommand:(SNOORedditCommand <SNOOURLRepresentable> *)command] ;
		}
	else
		{
		[command finishWithError:[NSError
			errorWithDomain:SNOOREDDITSERVICE_ERROR_DOMAIN
			code:xkSNOORedditServiceErrorUnknownCommand
			userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"I don't know how to handle a %@", [command class]]}]
			] ;
		} // if SNOOURLRepresentable
	}

- (void) handleNetworkingCommand: (SNOORedditCommand <SNOOURLRepresentable> *) command
	{
	NSParameterAssert([command isKindOfClass:[SNOORedditCommand class]]) ;
	NSParameterAssert([command conformsToProtocol:@protocol(SNOOURLRepresentable)]) ;
	
	NSURLRequest *urlRequest = [command URLRequestRepresentationWithRootURL:[NSURL URLWithString:REDDIT_ROOT]] ;
	
	// If there's no urlRequest returned, call the finishedBlock with an error and exit
	if( !urlRequest )
		{
		[command finishWithError:[NSError
			errorWithDomain:SNOOREDDITSERVICE_ERROR_DOMAIN
			code:xkSNOORedditServiceErrorMissingURLRequest
			userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"SNOOURLRepresentable %@ at %x has no URLRequestRepresentation", [command class], (unsigned int) command]}]
			] ;
		return ;
		}
	
	// Setup the network fetch
	AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest] ;
	requestOperation.responseSerializer = [AFJSONResponseSerializer serializer] ;
	[requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
		{
		NSError *error = nil ;
		if( [command handleResponseObject:responseObject error:&error] )
			{
			[command finishWithError:nil] ;
			}
		else
			{
			error = error ?: [NSError errorWithDomain:SNOOREDDITSERVICE_ERROR_DOMAIN code:xkSNOORedditServiceErrorUnknownError userInfo:@{NSLocalizedDescriptionKey:@"Command's handleResponseObject:error: failed but returned no error."}] ;
			[command finishWithError:error] ;
			}
		}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
		{
		[command finishWithError:error] ;
		}] ;
	
	// Before we fetch, let's set a way for the command to cancel itself. We don't want this to be captured strongly. If the request operation goes away (e.g., it completes), weakRequestOperation will be set to nil and -cancel will have no effect.
	__weak AFHTTPRequestOperation *weakOperation = requestOperation ;
	command.cancelBlock = ^
		{
		[weakOperation cancel] ;
		} ;
	
	// Perform the fetch
	[self.operationQueue addOperation:requestOperation] ;
	}

@end
