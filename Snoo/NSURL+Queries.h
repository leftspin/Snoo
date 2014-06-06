//
//  NSURL+Queries.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  http://stackoverflow.com/questions/6309698/objective-c-how-to-add-query-parameter-to-nsurl

@import Foundation ;

@interface NSURL (Queries)
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString ;
@end
