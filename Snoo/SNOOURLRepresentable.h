//
//  SNOOURLRepresentable.h
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//
//  A protocol for objects that can be represented by a URL and can handle the contents at that URL after it has been mapped

@import Foundation ;

@protocol SNOOURLRepresentable <NSObject>

@required
// Returns an NSURLRequest that represents the receiver on the service. This shouldn't return nil. If the receiver isn't representable by an NSURLRequest, it shouldn't adopt this protocol. rootURL will be passed to you by the service.
- (NSURLRequest *) URLRequestRepresentationWithRootURL: (NSURL *) rootURL ;

// Handle the response that resulted from fetching the request returned by -URLRequestRespresentation. Return YES if handling succeded, and NO otherwise. If you return NO, also provide an error.
- (BOOL) handleResponseObject: (id) responseObject error: (NSError **) error ;

@end
