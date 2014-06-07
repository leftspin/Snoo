//
//  _SNOOPost.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface _SNOOPost : NSManagedObject

@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSString * redditID;
@property (nonatomic, retain) NSString * selftext;
@property (nonatomic, retain) NSNumber * is_self;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * created_date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * service_order;
@property (nonatomic, retain) NSString * ui_context;

@end
