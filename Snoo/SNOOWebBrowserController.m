//
//  SNOOWebBrowserController.m
//  Snoo
//
//  Created by Mike Manzano on 12/4/13.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOWebBrowserController.h"

@interface SNOOWebBrowserController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButtonItem;
@end

@implementation SNOOWebBrowserController

#pragma mark - UIView

- (void) updateButtons
	{
	self.backButtonItem.enabled = self.webView.canGoBack ;
	self.forwardButtonItem.enabled = self.webView.canGoForward ;
	}

#pragma mark - Actions

- (IBAction)actionTapped:(UIBarButtonItem *)sender
	{
	}

- (IBAction)doneTapped:(UIBarButtonItem *)sender
	{
	[self dismissViewControllerAnimated:YES completion:nil] ;
	}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
	{
	return YES ;
	}

- (void)webViewDidStartLoad:(UIWebView *)webView
	{
	[self updateButtons] ;
	}

- (void)webViewDidFinishLoad:(UIWebView *)webView
	{
	
	}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
	{
	
	}


@end
