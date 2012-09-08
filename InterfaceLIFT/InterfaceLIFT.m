//
//  InterfaceLIFT.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "InterfaceLIFT.h"

@implementation InterfaceLIFT {
	NSString *_latestID;
	NSOperationQueue *_workQueue;
	NSOperationQueue *_wallpaperQueue;
	NSOperationQueue *_thumbQueue;
	NSMutableArray *_wallpapers;
	NSUInteger _currentOffset;
	
	NSButton *_nextPageButton;
}

@synthesize galleryView = _galleryView;

- (id)initWithBundle:(NSBundle *)bundle {
	self = [super initWithBundle:bundle];
	if (self) {
		_wallpapers = [NSMutableArray new];
		
		_workQueue = [[NSOperationQueue alloc] init];
		[_workQueue setMaxConcurrentOperationCount:1];
		
		_wallpaperQueue = [[NSOperationQueue alloc] init];
		[_wallpaperQueue setMaxConcurrentOperationCount:1];
		
		_thumbQueue = [[NSOperationQueue alloc] init];
		[_thumbQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void)dealloc {
	[_latestID release];
	[_workQueue release];
	[_wallpaperQueue release];
	[_thumbQueue release];
	[_wallpapers release];
	[_nextPageButton release];
	
	[super dealloc];
}

- (void)awakeFromNib {
	self.galleryView.footerView = [self nextPageButton];
}

- (NSButton *)nextPageButton {
	if (!_nextPageButton) {
		_nextPageButton = [[NSButton alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 182.0f, 32.0f)];
		[_nextPageButton setBezelStyle:NSSmallSquareBezelStyle];
		[_nextPageButton setTitle:@"Load Next Page"];
		[_nextPageButton setTarget:self];
		[_nextPageButton setAction:@selector(loadNextPageOfWallpapers)];
	}
	
	return _nextPageButton;
}

- (NSUInteger)numberOfImagesInGalleryView:(GalleryView *)view {
	return [_wallpapers count];
}

- (NSImage *)galleryView:(GalleryView *)view imageAtIndex:(NSUInteger)index {
	return [[_wallpapers objectAtIndex:index] thumbnail];
}

- (void)galleryView:(GalleryView *)view didSelectCellAtIndex:(NSUInteger)index {
	Wallpaper *wallpaper = [_wallpapers objectAtIndex:index];
	
	SetWallpaperOperation *op = [[SetWallpaperOperation alloc] initWithWallpaper:wallpaper];
	op.delegate = self;
	
	[_workQueue addOperation:op];
	[op release];
}

- (BOOL)galleryView:(GalleryView *)view isImageNewAtIndex:(NSUInteger)index {
	Wallpaper *wallpaper = [_wallpapers objectAtIndex:index];
	
	return [_latestID compare:wallpaper.identifier options:NSNumericSearch] == NSOrderedAscending;
}

- (NSString *)galleryView:(GalleryView *)view titleForImageAtIndex:(NSUInteger)index {
	Wallpaper *wallpaper = [_wallpapers objectAtIndex:index];
	
	return wallpaper.title;
}

- (void)setWallpaperOperationDidStartDownload:(SetWallpaperOperation *)operation {
	NSUInteger index = [_wallpapers indexOfObject:operation.wallpaper];
	
	[[_galleryView imageCellAtIndex:index] showOverlay];
}

- (void)setWallpaperOperationDidFinishDownload:(SetWallpaperOperation *)operation {
	NSUInteger index = [_wallpapers indexOfObject:operation.wallpaper];
	
	[[_galleryView imageCellAtIndex:index] hideOverlay];
}

- (void)mainViewDidLoad {
	[super mainViewDidLoad];
	
	_latestID = [[[NSUserDefaults standardUserDefaults] stringForKey:@"MRIL.LatestID"] copy];
	
	[self loadNextPageOfWallpapers];
}

- (void)loadNextPageOfWallpapers {
	// Setup the url and key
	NSString *hash = @"b3JvYXR6YjExcWhieTh4ZWxkcm00aGh3eTluaXBsOjIzMTcyMTExNTU4ZmViNDQ0NTFjZjRhYTMzN2ZiOTQwMDBkY2I3MWQ=";
	NSString *header = @"X-Mashape-Authorization";
	NSString *urlbase = @"https://interfacelift-interfacelift-wallpapers.p.mashape.com/v1/wallpapers/";
	
	// Parameters to use to make the API request
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject: @"20" forKey: @"limit"];
	
	// Build resolution string and set resolution param
	NSScreen *myScreen = [NSScreen mainScreen];
	NSRect screenRect = [myScreen frame];
	NSString *resString = [NSString stringWithFormat: @"%dx%d", (int) screenRect.size.width, (int) screenRect.size.height];
	[params setObject: resString forKey: @"resolution"];
	
	
	// build the url using the values in the dictionary (probably slow)
	NSMutableString *paramString = [NSMutableString stringWithString:@"?"];
	for(id key in params){
		[paramString appendString: [NSMutableString stringWithFormat: @"%@=%@%@", key, [params objectForKey: key], @"&"]];
	}
	
	NSString *totalUrl = [NSString stringWithFormat: @"%@%@", urlbase, paramString];
	
	// build the URL object and make the request
    NSURL *url = [NSURL URLWithString: totalUrl];
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL: url];
    [r setValue: hash forHTTPHeaderField: header];
	[r setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    
	[NSURLConnection sendAsynchronousRequest: r queue:_workQueue
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   
							   if (!data) {
								   NSLog(@"Could not fetch the Twitter feed. Error: %@", error);
								   return;
							   }
							   
							   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
								   [self parseTwitterFeedData:data];
							   }];
							   
						   }];
	_currentOffset += 20;
}

- (void)parseTwitterFeedData:(NSData *)data {
	
	//		Wallpaper *wallpaper = [[Wallpaper alloc] init];
	//		wallpaper.identifier = [item objectForKey:@"id_str"];
	//
	//		[_wallpapers addObject:wallpaper];
	//		[wallpaper release];
	//
	//		WallpaperRequestOperation *request = [[WallpaperRequestOperation alloc] initWithURL:url];
	//		request.wallpaper = wallpaper;
	//		request.delegate = self;
	//
	//		[_wallpaperQueue addOperation:request];
	//		[request release];
	//
	//		[indices addIndex:lastIndex++];
	//
	//
	//	if ([_wallpapers count]) {
	//		Wallpaper *newestWallpaper = [_wallpapers objectAtIndex:0];
	//
	//		if (newestWallpaper) {
	//			[[NSUserDefaults standardUserDefaults] setObject:newestWallpaper.identifier forKey:@"MRIL.LatestID"];
	//			[[NSUserDefaults standardUserDefaults] synchronize];
	//		}
	//	}
	//
	//	[self.galleryView insertImagesAtIndices:indices];
}

- (void)wallpaperRequestOperationDidComplete:(WallpaperRequestOperation *)operation {
	Wallpaper *wallpaper = operation.wallpaper;
	
	[_thumbQueue addOperationWithBlock:^{
		
		NSImage *image = [[[NSImage alloc] initWithContentsOfURL:wallpaper.previewURL] autorelease];
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			
			wallpaper.thumbnail = image;
			
			NSUInteger index = [_wallpapers indexOfObject:wallpaper];
			[self.galleryView reloadImageCellAtIndex:index];
			
		}];
		
	}];
}

@end
