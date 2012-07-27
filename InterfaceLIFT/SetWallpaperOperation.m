//
//  SetWallpaperOperation.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "SetWallpaperOperation.h"

#import "Wallpaper.h"

@implementation SetWallpaperOperation {
	NSURL *_url;
	NSString *_path;
	NSURLDownload *_download;
}

#define USER_AGENT @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1"

@synthesize wallpaper = _wallpaper, delegate = _delegate;

- (id)initWithWallpaper:(Wallpaper *)wallpaper {
	NSParameterAssert(wallpaper);
	
	self = [super init];
	if (self) {
		_url = [[wallpaper downloadURL] retain];
		_wallpaper = [wallpaper retain];
	}
	return self;
}

- (void)dealloc {
	[_url release];
	[_wallpaper release];
	[_path release];
	[_download release];
	
	[super dealloc];
}

- (NSString *)destinationPathWithFileName:(NSString *)fileName {
    
	NSString *appSupportPath = [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) lastObject];
	appSupportPath = [appSupportPath stringByAppendingPathComponent:@"InterfaceLIFT"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:appSupportPath isDirectory:NULL]) {
		[fileManager createDirectoryAtPath:appSupportPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return [appSupportPath stringByAppendingPathComponent:fileName];
}

- (void)setDesktopImageAtPath:(NSString *)path {
	NSError *error = nil;
	
	if (![[NSWorkspace sharedWorkspace] setDesktopImageURL:[NSURL fileURLWithPath:path]
												 forScreen:[NSScreen mainScreen]
												   options:nil
													 error:&error]) {
		
		NSLog(@"Could not set desktop image. Error: %@", error);
	}
}

- (void)startOnMainThread {
	NSString *destinationPath = [self destinationPathWithFileName:[_url lastPathComponent]];
	BOOL isDirectory = NO;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:&isDirectory] && !isDirectory) {
		[self setDesktopImageAtPath:destinationPath];
		
		self.executing = NO;
		self.finished = YES;
		
		return;
	}
	
	[_delegate setWallpaperOperationDidStartDownload:self];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
	[request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	_path = [destinationPath retain];
	
	self.executing = YES;
	
	_download = [[NSURLDownload alloc] initWithRequest:request delegate:self];
	[_download setDestination:destinationPath allowOverwrite:YES];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error {
#warning TODO: handle errors
}

- (void)downloadDidFinish:(NSURLDownload *)download {
	[self setDesktopImageAtPath:_path];
	
	[_delegate setWallpaperOperationDidFinishDownload:self];
	
	self.executing = NO;
	self.finished = YES;
}

@end
