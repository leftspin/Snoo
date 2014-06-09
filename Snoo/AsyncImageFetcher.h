//
//  AsyncImageFetcher.h
//  easybook
//
//  Created by Mike Manzano on 3/25/11.
//  Copyright 2011 IVM. All rights reserved.
//
//	v1.1 Uses a string as the cache key instead of an NSURL object
//  v1.2 Uses an SHA256 digest as the cache key
//	     Cache is now disk-based
//	v1.2.1 Modernized some code
//  v1.2.2 Made cache writing asynchronous
//  v1.3 Added reactive methods

@import Foundation ;
#import <dispatch/dispatch.h>

typedef void (^fetchImagePerformBlock)(UIImage *image, BOOL usingCached) ;

#define ASYNC_IMAGE_FETCHER_ERROR_DOMAIN @"ASYNC_IMAGE_FETCHER_ERROR_DOMAIN"

typedef enum xeAsyncImageFetcherError : NSUInteger
	{
	xkAsyncImageFetcherErrorInvalidURL = 0 ,
	xkAsyncImageFetcherErrorImageFetchFailed ,
	} xeAsyncImageFetcherError ;

@interface AsyncImageFetcher : NSObject 

+ (AsyncImageFetcher *) sharedImageFetcher ;
- (void) fetchImageAtURL: (NSURL *) imageURL cache: (BOOL) cache andPerform: (fetchImagePerformBlock) postBlock ;
+ (NSString*)computeSHA256DigestForString:(NSString*)input ; // Other things might use this
+ (void) deleteOldImages ;
- (void) invalidateImageAtURL: (NSURL *) imageURL ; // Remove image with URL from the cache

// Returns a signal that emits UIImages. If for whatever reason imageURL doesn't result in an image, emits an error
//+ (RACSignal *) imageAtURL: (NSURL *) imageURL cache: (BOOL) cache ;
@end
