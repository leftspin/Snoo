//
//  _SNOOPost.h
//  Snoo
//
//  Created by Mike Manzano on 6/8/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface _SNOOPost : NSManagedObject

@property (nonatomic, retain) NSDate * created_date;
@property (nonatomic, retain) NSNumber * is_self;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSString * redditID;
@property (nonatomic, retain) NSString * selftext;
@property (nonatomic, retain) NSNumber * service_order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * ui_context;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * num_comments;
@property (nonatomic, retain) NSString * thumbnail;

@end
