//
//  AsyncImageFetcher.m
//  easybook
//
//  Created by Mike Manzano on 3/25/11.
//  Copyright 2011 IVM. All rights reserved.
//

#import "AsyncImageFetcher.h"
@import Security ;
#import <CommonCrypto/CommonHMAC.h>

#define CACHED_IMAGES_FOLDER @"cached_images"
#define IN_MEMORY_CACHE_FILE_LIMIT 50

@implementation AsyncImageFetcher
	{
	NSMutableDictionary *imagePostBlocks_ ;
	NSMutableDictionary *_inMemoryImageCache ;
	NSMutableArray *_inMemoryImageCacheKeyEnumeration ; // stores keys to the _inMemoryImageCache in order of last used
	dispatch_queue_t imageFetchQueue_, _diskWriteQueue ;
	
	// Thread safety
	NSLock *_lock ;
	}

#pragma mark - Utility

+ (NSString*)computeSHA256DigestForString:(NSString*)input
	{
	
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
	
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (CC_LONG) data.length, digest);
	
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
	
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
	
    return output;
	}

#pragma mark - Disk

- (NSURL *) targetURLWithFilename: (NSString *) fileName
	{
	static NSURL *docsDirURL ;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
		{
		docsDirURL = [UIApplication snooAppDelegate].applicationDocumentsDirectory ;
		}) ;
	return [[docsDirURL URLByAppendingPathComponent:CACHED_IMAGES_FOLDER] URLByAppendingPathComponent:fileName] ;
	}

- (void) saveImage: (UIImage *) image toFileWithName: (NSString *) fileName
	{
	if( _inMemoryImageCache[fileName] != nil )
		{
		// Move the key up
//		NSLog(@"Moved %@ up in cache" , fileName) ;
		[_inMemoryImageCacheKeyEnumeration removeObject:fileName] ;
		[_inMemoryImageCacheKeyEnumeration insertObject:fileName atIndex:0] ;
		return ; // already saved
		}
	
	if( _inMemoryImageCacheKeyEnumeration.count > IN_MEMORY_CACHE_FILE_LIMIT )
		{
		// Remove the last item
		NSLog(@"Uncached %@", _inMemoryImageCacheKeyEnumeration.lastObject) ;
		[_inMemoryImageCache removeObjectForKey:_inMemoryImageCacheKeyEnumeration.lastObject] ;
		[_inMemoryImageCacheKeyEnumeration removeLastObject] ;
		}
	
//	NSLog(@"Memory caching %@" , fileName) ;
	[_inMemoryImageCacheKeyEnumeration insertObject:fileName atIndex:0] ;
	_inMemoryImageCache[fileName] = image ;
	
	NSURL *targetURL = [self targetURLWithFilename:fileName] ;
	
	dispatch_async(_diskWriteQueue, ^
		{
#warning http://stackoverflow.com/questions/12391424/png-error-inside-uiimagepngrepresentation-only-on-ios-5-1 
		NSData *imageData = UIImageJPEGRepresentation(image,1) ;
		//		imageData = UIImagePNGRepresentation(image) ;
		NSError *error = nil ;
		[imageData writeToURL:targetURL options:NSDataWritingAtomic error:&error] ;
		
		dispatch_async(dispatch_get_main_queue(), ^
			{
			if( error ) NSLog(@"Async image cache write error: %@" , error) ;
			}) ;
		}) ;
	}

- (UIImage *) imageWithFileName: (NSString *) fileName
	{
	UIImage *inMemoryImage = _inMemoryImageCache[fileName] ;
	if( inMemoryImage )
		{
//		NSLog(@"Moved %@ up in cache for access" , fileName) ;
		[_inMemoryImageCacheKeyEnumeration removeObject:fileName] ;
		[_inMemoryImageCacheKeyEnumeration insertObject:fileName atIndex:0] ;
		return inMemoryImage ;
		}
	
	NSURL *targetURL = [self targetURLWithFilename:fileName] ;
	NSData *imageData = [NSData dataWithContentsOfURL:targetURL] ;
	UIImage *image = [UIImage imageWithData:imageData] ;
	
	if( image )
		{
		if( _inMemoryImageCacheKeyEnumeration.count > IN_MEMORY_CACHE_FILE_LIMIT )
			{
			// Remove the last item
//			NSLog(@"Uncached %@ because of file read", _inMemoryImageCacheKeyEnumeration.lastObject) ;
			[_inMemoryImageCache removeObjectForKey:_inMemoryImageCacheKeyEnumeration.lastObject] ;
			[_inMemoryImageCacheKeyEnumeration removeLastObject] ;
			}

//		NSLog(@"Memory caching %@ due to file read" , fileName) ;
		[_inMemoryImageCacheKeyEnumeration insertObject:fileName atIndex:0] ;
		_inMemoryImageCache[fileName] = image ;
		}

	return image ;
	}

- (void) invalidateImageAtURL: (NSURL *) imageURL
	{
	NSString *imageCacheKey = [AsyncImageFetcher computeSHA256DigestForString:[imageURL absoluteString]] ;
	if( imageCacheKey.length == 0 )
		return ;
	[_inMemoryImageCache removeObjectForKey:imageCacheKey] ;
	NSURL *targetURL = [self targetURLWithFilename:imageCacheKey] ;
	NSFileManager *fm = [NSFileManager defaultManager] ;
	NSError *deleteError = nil ;
	[fm removeItemAtURL:targetURL error:&deleteError] ;
	}

#pragma mark - AsyncImageFetcher

- (void) fetchImageAtURL: (NSURL *) imageURL cache: (BOOL) cache andPerform: (fetchImagePerformBlock) postBlock
	{
	if( !imageURL )
		{
		if( postBlock )
			postBlock(nil, YES) ;
		return ;
		}
	
	NSString *imageCacheKey = [AsyncImageFetcher computeSHA256DigestForString:[imageURL absoluteString]] ;
	if( imageCacheKey.length == 0 )
		return ;
	
	// Have we already cached this URL?
	UIImage *cachedImage = [self imageWithFileName:imageCacheKey] ;
	if( cachedImage )
		{
		// Just execute the post block with this image
		if( postBlock )
			postBlock( cachedImage, YES ) ;
		}
	else
		{
		BOOL createdPostBlocks = NO ;
		if( postBlock )
			{
			// Queue the post block and start the image fetch. Note, there may
			// already be a queue of post blocks
			if( [_lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:7]] )
				{
				NSMutableArray *postBlocks = [imagePostBlocks_ objectForKey:imageCacheKey] ;
				if(!postBlocks)
					{
					postBlocks = [NSMutableArray arrayWithCapacity:1] ;
					[imagePostBlocks_ setObject:postBlocks forKey:imageCacheKey] ;
					createdPostBlocks = YES ;
					}
				[postBlocks addObject:[postBlock copy]] ;
				[_lock unlock] ;
				} // lock
			else
				{
				NSLog(@"DEADLOCK DETECTED in AsyncImageFetcher\n%@", [NSThread callStackSymbols]) ;
				} // lock
			} // if postBlock

		// If we created the post blocks, start the fetch, otherwise we're done
		if( createdPostBlocks )
			{
			dispatch_async(imageFetchQueue_, ^(void) 
				{
				UIImage *fetchedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]] ;
				
				dispatch_async(dispatch_get_main_queue(), ^(void) 
					{
					if( [_lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:7]] )
						{
						// Execute any post blocks that we have
						NSArray *postBlocks = [imagePostBlocks_ objectForKey:imageCacheKey] ;
						[postBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
							{
							fetchImagePerformBlock postBlock = (fetchImagePerformBlock) obj ;
							
							dispatch_async(dispatch_get_main_queue(), ^
								{
								postBlock(fetchedImage, NO) ;
								}) ;
							
							// Cache this image if it's actually there
							if( fetchedImage && imageURL && cache )
								[self saveImage:fetchedImage toFileWithName:imageCacheKey] ;
							}] ; // each post block
						
						// Clear these post blocks
						[imagePostBlocks_ removeObjectForKey:imageCacheKey] ;
						[_lock unlock] ;
						} // lock
					else
						{
						NSLog(@"DEADLOCK DETECTED in AsyncImageFetcher\n%@", [NSThread callStackSymbols]) ;
						}
					}) ; // perform postBlocks on main queue
				}) ; // start image fetch async on fetch queue
			 } // we created post blocks?
		} // if cachedImage
	}


#pragma mark - Class

+ (void) deleteOldImages
	{
	NSFileManager *fm = [NSFileManager defaultManager] ;
	NSError *error = nil ;
	NSArray *imageFileURLs = [fm contentsOfDirectoryAtURL:[[UIApplication snooAppDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:CACHED_IMAGES_FOLDER] includingPropertiesForKeys:@[NSURLContentAccessDateKey] options:0 error:&error] ;
	if( !error )
		{
		[imageFileURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
			{
			NSURL *fileURL = (NSURL *) obj ;
#define SECONDS_IN_A_WEEK (604800)
			NSDate *aWeekAgo = [NSDate dateWithTimeIntervalSinceNow:-SECONDS_IN_A_WEEK] ;
			NSDate *lastAccessDate = nil ;
			NSError *getResourceError = nil ;
			if( [fileURL getResourceValue:&lastAccessDate forKey:NSURLContentAccessDateKey error:&getResourceError] )
				{
				if( [lastAccessDate compare:aWeekAgo] == NSOrderedAscending )
					{
//					NSLog(@"Delete %@: %@", fileURL.absoluteString, lastAccessDate) ;
					NSError *deleteError = nil ;
					[fm removeItemAtURL:fileURL error:&deleteError] ;
//					if( !deleteError )
//						NSLog(@"\tsuccess") ;
//					else
//						NSLog(@"\tfail: %@" , deleteError) ;
					}
//				else
//					NSLog(@"Keep %@: %@", fileURL.absoluteString, lastAccessDate) ;
				}
			else
				NSLog(@"Could not get last access date for file at %@" , fileURL) ;
			}] ;
		}
	else
		NSLog(@"AsyncImageFetcher: Unable to get contents of %@: %@", [[UIApplication snooAppDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:CACHED_IMAGES_FOLDER], error) ;
	}

+ (AsyncImageFetcher *) sharedImageFetcher
	{
	static AsyncImageFetcher *imageFetcher ;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
		{
		imageFetcher = [[AsyncImageFetcher alloc]init] ;
		
		// If the cached_images directory doesn't exist, create it
		NSFileManager *manager = [NSFileManager defaultManager] ;
		BOOL isDirectory = NO ;
		BOOL cacheDirectoryExists = [manager fileExistsAtPath:[[[UIApplication snooAppDelegate].applicationDocumentsDirectory path] stringByAppendingPathComponent:CACHED_IMAGES_FOLDER] isDirectory:&isDirectory] ;
		if( cacheDirectoryExists )
			NSAssert( isDirectory , @"Async image cache directory exists, but it's not a folder" ) ;
		else
			{
			NSError *error = nil ;
			[manager createDirectoryAtURL:[[UIApplication snooAppDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:CACHED_IMAGES_FOLDER] withIntermediateDirectories:YES attributes:nil error:&error] ;
			if( error ) NSLog( @"Error while creating async image cache directory: %@" , error ) ;
			}
		}) ;
	
	return imageFetcher ;
	}

#pragma mark - RAC

//+ (RACSignal *) imageAtURL: (NSURL *) imageURL cache: (BOOL) cache
//	{
//	if( !imageURL )
//		return [RACSignal error:[NSError errorWithDomain:ASYNC_IMAGE_FETCHER_ERROR_DOMAIN code:xkAsyncImageFetcherErrorInvalidURL userInfo:nil]] ;
//				
//	RACReplaySubject *subject = [RACReplaySubject replaySubjectWithCapacity:1] ;
//	
//	[[AsyncImageFetcher sharedImageFetcher] fetchImageAtURL:imageURL cache:cache andPerform:^(UIImage *image, BOOL usingCached)
//		{
//		if( image )
//			{
//			[subject sendNext:image] ;
//			[subject sendCompleted] ;
//			}
//		else
//			[subject sendError:[NSError errorWithDomain:ASYNC_IMAGE_FETCHER_ERROR_DOMAIN code:xkAsyncImageFetcherErrorImageFetchFailed userInfo:nil]] ;
//		}] ;
//	
//	return [subject deliverOn:RACScheduler.mainThreadScheduler] ;
//	}


#pragma mark - Instance

- (id) init
	{
	self = [super init] ;
	if( self )
		{
		imagePostBlocks_ = [[NSMutableDictionary alloc] initWithCapacity:20] ;
		imageFetchQueue_ = dispatch_queue_create("com.ivm.snoo.imageFetchQueue", NULL) ;
		_diskWriteQueue = dispatch_queue_create("com.ivm.snoo.imageCacheWriteQueue", DISPATCH_QUEUE_CONCURRENT) ;
		_inMemoryImageCache = [[NSMutableDictionary alloc] initWithCapacity:IN_MEMORY_CACHE_FILE_LIMIT] ;
		_inMemoryImageCacheKeyEnumeration = [[NSMutableArray alloc] initWithCapacity:IN_MEMORY_CACHE_FILE_LIMIT] ;
		_lock = [[NSLock alloc] init] ;
		}
	return self ;
	}

@end
