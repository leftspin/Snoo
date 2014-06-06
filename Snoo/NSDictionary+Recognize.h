//
//  NSDictionary+Recognize.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

@import Foundation ;
#import "SNOORedditConstants.h"

@interface NSDictionary (Recognize)

// Returns one of xeRedditStructureType if recognized, or xkRedditStructureTypeUnknown
- (xeRedditStructureType) structureType ;

@end
