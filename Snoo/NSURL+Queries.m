//
//  NSURL+Queries.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  http://stackoverflow.com/questions/6309698/objective-c-how-to-add-query-parameter-to-nsurl

#import "NSURL+Queries.h"

@implementation NSURL (Queries)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString
	{
    if (![queryString length])
		{
        return self ;
		}
	
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    return theURL;
	}

@end
