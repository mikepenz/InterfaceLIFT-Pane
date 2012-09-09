//
//  InterfaceLIFT.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "InterfaceLIFT.h"

#import "Wallpaper.h"

#define USER_AGENT @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1"
#define HASH @"b3JvYXR6YjExcWhieTh4ZWxkcm00aGh3eTluaXBsOjIzMTcyMTExNTU4ZmViNDQ0NTFjZjRhYTMzN2ZiOTQwMDBkY2I3MWQ="
#define HEADER @"X-Mashape-Authorization"

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
	
	// Setup the url and key
	NSString *urlbase = @"https://interfacelift-interfacelift-wallpapers.p.mashape.com/v1/wallpaper_download/%@/%@/";
	
	// Build resolution string and set resolution param
	NSScreen *myScreen = [NSScreen mainScreen];
	NSRect screenRect = [myScreen frame];
	NSString *resString = [NSString stringWithFormat: @"%dx%d", (int) screenRect.size.width, (int) screenRect.size.height];
	NSString *totalUrl = [NSString stringWithFormat:urlbase, wallpaper.identifier, resString];
	
	// build the URL object and make the request
    NSURL *url = [NSURL URLWithString: totalUrl];
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL: url];
    [r setValue: HASH forHTTPHeaderField: HEADER];
	[r setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
	[r setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	[NSURLConnection sendAsynchronousRequest: r queue:_workQueue
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   
							   if (!data) {
								   NSLog(@"Could not fetch wallpapers! Error: %@", error);
								   return;
							   }
							   
							   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
								   [self parseWallpaperDownload:data identifier:wallpaper.identifier];
							   }];
							   
						   }];
}

- (void)parseWallpaperDownload:(NSData *)data identifier:(NSString *)identifier {
	NSDictionary *wallpaperDownload = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	NSURL *url = [NSURL URLWithString:[wallpaperDownload objectForKey:@"download_url"]];
	
	NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL: url];
    [r setValue: HASH forHTTPHeaderField: HEADER];
	[r setValue: @"image/jpeg" forHTTPHeaderField: @"Content-Type"];
	[r setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	[NSURLConnection sendAsynchronousRequest: r queue: [NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   
							   if (!data) {
								   NSLog(@"Could not fetch wallpaper! Error: %@", error);
								   return;
							   }
							   
							   NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"wallpaper-%@.jpg", identifier]];
							   
							   [data writeToFile:path options:0 error:nil];
							   
							   [[NSWorkspace sharedWorkspace] setDesktopImageURL:[NSURL fileURLWithPath:path]
																	   forScreen:[NSScreen mainScreen] options:nil error:nil];
						   }];
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
	NSString *urlbase = @"https://interfacelift-interfacelift-wallpapers.p.mashape.com/v1/wallpapers/";
	
	// Parameters to use to make the API request
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:@"21" forKey:@"limit"];
	[params setObject:[NSString stringWithFormat:@"%ld", _currentOffset] forKey:@"start"];
	
	// Build resolution string and set resolution param
	NSRect screenRect = [[NSScreen mainScreen] frame];
	NSString *resString = [NSString stringWithFormat:@"%dx%d", (int) screenRect.size.width, (int) screenRect.size.height];
	[params setObject:resString forKey:@"resolution"];
	
	// build the url using the values in the dictionary (probably slow)
	NSMutableString *paramString = [NSMutableString stringWithString:@"?"];
	
	for (NSString *key in params) {
		[paramString appendString:[NSMutableString stringWithFormat:@"%@=%@%@", key, [params objectForKey:key], @"&"]];
	}
	
	// build the URL object and make the request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlbase, paramString]];
	
    NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:url];
    [r setValue:HASH forHTTPHeaderField:HEADER];
	[r setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:r queue:_workQueue
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   
							   if (!data) {
								   NSLog(@"Could not fetch wallpapers! Error: %@", error);
								   return;
							   }
							   
							   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
								   [self parseWallpapersFeed:data];
							   }];
							   
						   }];
	
	_currentOffset += 21;
}

- (void)parseWallpapersFeed:(NSData *)data {
	NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
	NSUInteger lastIndex = [_wallpapers count];
	
	NSArray *wallpapers = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	for(id item in wallpapers){
		NSURL *previewUrl = [NSURL URLWithString:[item objectForKey: @"preview_url"]];
		
		Wallpaper *wallpaper = [[Wallpaper alloc] init];
		wallpaper.identifier = [[item objectForKey:@"id"] stringValue];
		wallpaper.previewURL = previewUrl;
		wallpaper.title = [item objectForKey:@"title"];
		
		[_wallpapers addObject:wallpaper];
		[wallpaper release];
		
		[_thumbQueue addOperationWithBlock:^{
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:wallpaper.previewURL];
			[request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
			NSData *imageData = [NSURLConnection sendSynchronousRequest:request
													  returningResponse:nil error:nil];
			
			NSImage *image = [[[NSImage alloc] initWithData:imageData] autorelease];
			
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				
				wallpaper.thumbnail = image;
				
				NSUInteger index = [_wallpapers indexOfObject:wallpaper];
				[self.galleryView reloadImageCellAtIndex:index];
				
			}];
		}];
		
		
		[indices addIndex:lastIndex++];
	}
	
	if ([_wallpapers count]) {
		Wallpaper *newestWallpaper = [_wallpapers objectAtIndex:0];
		
		if (newestWallpaper) {
			[[NSUserDefaults standardUserDefaults] setObject:newestWallpaper.identifier forKey:@"MRIL.LatestID"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
	
	[self.galleryView insertImagesAtIndices:indices];
}

@end
