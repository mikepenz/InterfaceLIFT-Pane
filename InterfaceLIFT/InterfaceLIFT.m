//
//  InterfaceLIFT.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "InterfaceLIFT.h"

@implementation InterfaceLIFT {
	NSOperationQueue *_workQueue;
	NSOperationQueue *_wallpaperQueue;
	NSOperationQueue *_thumbQueue;
	NSMutableArray *_wallpapers;
	NSUInteger _currentPage;
	
	NSButton *_nextPageButton;
}

#define TWEET_BUTTON_IDENTIFIER @"<a href=\"http://twitter.com/tweetbutton\" rel=\"nofollow\">Tweet Button</a>"

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
	NSString *latestID = [[NSUserDefaults standardUserDefaults] objectForKey:@"MRIL.LatestID"];
	Wallpaper *wallpaper = [_wallpapers objectAtIndex:index];
	
	return [latestID compare:wallpaper.identifier options:NSNumericSearch] == NSOrderedAscending;
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
	
	[self loadNextPageOfWallpapers];
}

- (void)loadNextPageOfWallpapers {
	_currentPage++;
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&screen_name=interfacelift&count=21&page=%ld", _currentPage];
	NSURL *feedURL = [NSURL URLWithString:urlString];
	
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:feedURL]
									   queue:_workQueue
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   
							   if (!data) {
								   NSLog(@"Could not fetch the Twitter feed. Error: %@", error);
								   return;
							   }
							   
							   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
								   [self parseTwitterFeedData:data];
							   }];
							   
						   }];
}

- (void)parseTwitterFeedData:(NSData *)data {
	NSError *error = nil;
	NSArray *tree = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	if (!tree || ![tree isKindOfClass:[NSArray class]]) {
		NSLog(@"Could not parse the Twitter feed. Error: %@", error);
		return;
	}
	
	NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
	
	NSUInteger lastIndex = [_wallpapers count];
	
	for (NSDictionary *item in tree) {
		if (![[item objectForKey:@"source"] isEqualToString:TWEET_BUTTON_IDENTIFIER])
			continue;
		
		NSDictionary *entities = [item objectForKey:@"entities"];
		NSString *urlString = [[[entities objectForKey:@"urls"] lastObject] objectForKey:@"expanded_url"];
		
		if (!urlString)
			continue;
		
		NSURL *url = [NSURL URLWithString:urlString];
		
		Wallpaper *wallpaper = [[Wallpaper alloc] init];
		wallpaper.identifier = [item objectForKey:@"id_str"];
		
		[_wallpapers addObject:wallpaper];
		[wallpaper release];
		
		WallpaperRequestOperation *request = [[WallpaperRequestOperation alloc] initWithURL:url];
		request.wallpaper = wallpaper;
		request.delegate = self;
		
		[_wallpaperQueue addOperation:request];
		[request release];
		
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
