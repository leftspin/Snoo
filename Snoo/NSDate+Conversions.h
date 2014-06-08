//
//  NSDate+Conversions.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Conversions)
+ (NSDate *) dateFromUTCEpochTime: (NSNumber *) utcEpochTime ;
@end
