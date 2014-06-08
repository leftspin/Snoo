//
//  SNOOPostTableViewCell.h
//  Snoo
//
//  Created by Mike Manzano on 6/6/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SNOO_POST_TABLEVIEW_CELL_ID @"SNOO_POST_TABLEVIEW_CELL_ID"

@interface SNOOPostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

+ (instancetype) exemplar ;
+ (CGFloat) heightWithPostText: (NSString *) text ;

@end
