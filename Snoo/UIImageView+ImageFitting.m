//
//  UIImageView+ImageFitting.m
//  Snoo
//
//  Created by Mike Manzano on 6/8/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "UIImageView+ImageFitting.h"
#import "UIImage+ImageEffects.h"

@implementation UIImageView (ImageFitting)

- (UIImage *) fitImage: (UIImage *) sourceImage
	{
	if( !sourceImage )
		return nil ;
	CGFloat screenScale = [UIScreen mainScreen].scale ;
	CGFloat nominalWidth = self.frame.size.width * screenScale ;
	CGFloat nominalHeight = self.frame.size.height * screenScale ;

	if( nominalWidth == 0 || nominalHeight == 0 )
		return nil ; // could be the image view isn't instantiated yet

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB() ;
	CGContextRef context = CGBitmapContextCreate(NULL, nominalWidth, nominalHeight, CGImageGetBitsPerComponent(sourceImage.CGImage), 0, colorSpace /*CGImageGetColorSpace(sourceImage.CGImage)*/, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little /*CGImageGetBitmapInfo(sourceImage.CGImage)*/) ;

	if( !context )
		{
		CGColorSpaceRelease(colorSpace) ;
		return nil ;
		}

	// scale the image to make sure it fills width and height
	CGFloat width, height, scaledHeight, scaledWidth ;

	scaledHeight = (sourceImage.size.height * nominalWidth) / sourceImage.size.width ;
	scaledWidth = (sourceImage.size.width * nominalHeight) / sourceImage.size.height ;

	if( scaledHeight < nominalHeight )
		{
		height = nominalHeight ;
		width = scaledWidth ;
		}
	else if (scaledWidth < nominalWidth )
		{
		width = nominalWidth ;
		height = scaledHeight ;
		}
	else
		{
		width = nominalWidth ;
		height = scaledHeight ;
		}

	CGContextSetInterpolationQuality(context, kCGInterpolationNone) ;
	CGContextDrawImage(context, CGRECTMAKEF(-((width - nominalWidth)/2.0), (nominalHeight-height)+1, width, height), sourceImage.CGImage) ; // center width

	CGImageRef newImageRef = CGBitmapContextCreateImage(context) ;
	UIImage *newImage = [[UIImage alloc] initWithCGImage:newImageRef scale:screenScale orientation:UIImageOrientationUp] ;

	CGImageRelease(newImageRef) ;
	CGContextRelease(context) ;
	CGColorSpaceRelease(colorSpace) ;

	return newImage ;
	}


@end
