//
//  SNOOSelfTextController.h
//  Snoo
//
//  Created by Mike Manzano on 6/8/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SNOO_SELF_TEXT_CONTROLLER_ID @"SNOO_SELF_TEXT_CONTROLLER_ID"

@interface SNOOSelfTextController : UIViewController
@property (nonatomic, strong) NSString *initialText ;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end
