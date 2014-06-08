//
//  NSDate(FriendlyDate).h
//  Newsie
//
//  Created by Mike Manzano on 5/20/09.
//  Copyright 2009 IVM. All rights reserved.
//

@import Foundation ;

@interface NSDate (FriendlyDate)

+ (NSString *) friendlyDateWithJSONDate: (unsigned long long) jsonDate ;
+ (NSDate *) dateWithJSONDate: (unsigned long long) jsonDate ;
- (NSString *) friendlyDateWithEndDate: (NSDate *) endDate ;
- (NSString *) abbreviatedFriendlyDate ;
- (NSString*) JSON ;
@end
