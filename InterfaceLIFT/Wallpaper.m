//
//  Wallpaper.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "Wallpaper.h"

@implementation Wallpaper

#define MAGIC_DOWNLOAD_KEY @"7yz4ma1"

@synthesize title, identifier, previewURL = _previewURL, thumbnail;

- (NSURL *)downloadURL {
	if (_previewURL == nil)
		return nil;
	
	int screenWidth = (int) CGRectGetWidth([NSScreen mainScreen].frame);
	int screenHeight = (int) CGRectGetHeight([NSScreen mainScreen].frame);
	
	NSString *downloadURLString = [[_previewURL absoluteString] stringByReplacingOccurrencesOfString:@"previews"
																						  withString:MAGIC_DOWNLOAD_KEY];
	
	NSString *resolutionString = [NSString stringWithFormat:@"_%dx%d.jpg", screenWidth, screenHeight];
	
	downloadURLString = [downloadURLString stringByReplacingOccurrencesOfString:@".jpg"
																	 withString:resolutionString];
	
	return [NSURL URLWithString:downloadURLString];
}

- (void)dealloc {
	[title release];
	[identifier release];
	[_previewURL release];
	[thumbnail release];
	
	[super dealloc];
}

@end
