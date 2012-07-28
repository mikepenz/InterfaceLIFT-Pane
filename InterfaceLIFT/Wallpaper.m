//
//  Wallpaper.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "Wallpaper.h"

@implementation Wallpaper

#define MAGIC_DOWNLOAD_KEY @"7yz4ma1"

@synthesize title, identifier, previewURL = _previewURL, downloadURL, thumbnail;

- (NSURL *)downloadURL {
	if (_previewURL == nil)
		return nil;
    
    //RETINA
	//int screenWidth = (int) 3840;
	//int screenHeight = (int) 2400;
    //RETINA
	int screenWidth = (int) 2880;
	int screenHeight = (int) 1800;
    //2560x1600
	//int screenWidth = (int) 2560;
	//int screenHeight = (int) 1600;
	//1920x1200
    //int screenWidth = (int) 1920;
	//int screenHeight = (int) 1200;
    //1920x1080
	//int screenWidth = (int) 1920;
	//int screenHeight = (int) 1080;
    //1280x800
	//int screenWidth = (int) 1280;
	//int screenHeight = (int) 800;
    //1366x768
	//int screenWidth = (int) 1366;
	//int screenHeight = (int) 768;
    //1280x800
	//int screenWidth = (int) 1280;
	//int screenHeight = (int) 720;
    //1440x900
	//int screenWidth = (int) 1440;
	//int screenHeight = (int) 900;
	
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
