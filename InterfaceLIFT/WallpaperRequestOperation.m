//
//  WallpaperRequestOperation.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "WallpaperRequestOperation.h"

#import <WebKit/WebKit.h>

@implementation WallpaperRequestOperation {
	NSURL *_url;
	WebView *_webView;
}

#define TITLE_PREFIX @"InterfaceLIFT Wallpaper: "

@synthesize wallpaper = _wallpaper, delegate = _delegate;

- (id)initWithURL:(NSURL *)url {
	NSParameterAssert(url);
	
	self = [super init];
	if (self) {
		_url = [url retain];
	}
	return self;
}

- (void)dealloc {
	[_url release];
	[_wallpaper release];
	[_webView release];
	
	[super dealloc];
}

- (void)startOnMainThread {
	_webView = [[WebView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 200.0f, 200.0f)];
	[_webView setFrameLoadDelegate:self];
	[_webView setResourceLoadDelegate:self];
	
	[[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:_url]];
	
	self.executing = YES;
}

- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
		  willSendRequest:(NSURLRequest *)request
		 redirectResponse:(NSURLResponse *)redirectResponse
		   fromDataSource:(WebDataSource *)dataSource {
	
	NSString *urlString = [[request URL] absoluteString];
	
	// allow redirect
	if ([urlString rangeOfString:@".cc"].location != NSNotFound)
		return request;
	
	// only load the index page
	if ([[urlString pathExtension] isEqualToString:@"html"])
		return request;
	
	return nil;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	if (frame != [sender mainFrame])
		return;
	
	NSString *linkJS = @"document.head.getElementsByTagName('link')[3]['href']";
	NSString *previewLink = [_webView stringByEvaluatingJavaScriptFromString:linkJS];
	NSURL *previewURL = [NSURL URLWithString:previewLink];
	
	NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	NSString *extractedTitle = nil;
	
	NSScanner *titleScanner = [[NSScanner alloc] initWithString:title];
	[titleScanner scanString:TITLE_PREFIX intoString:nil];
	[titleScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&extractedTitle];
	[titleScanner release];
	
	_wallpaper.previewURL = previewURL;
	_wallpaper.title = extractedTitle;
	
	[self.delegate wallpaperRequestOperationDidComplete:self];
	
	self.executing = NO;
	self.finished = YES;
}

@end
