//
//  Wallpaper.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "Wallpaper.h"

@implementation Wallpaper

@synthesize title, identifier, previewURL = _previewURL, thumbnail;

- (void)dealloc {
	[title release];
	[identifier release];
	[_previewURL release];
	[thumbnail release];
	
	[super dealloc];
}

@end
