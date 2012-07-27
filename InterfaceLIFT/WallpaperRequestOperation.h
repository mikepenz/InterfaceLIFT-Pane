//
//  WallpaperRequestOperation.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "ConcurrentOperation.h"
#import "Wallpaper.h"

@protocol WallpaperRequestOperationDelegate;

@interface WallpaperRequestOperation : ConcurrentOperation

@property (strong) Wallpaper *wallpaper;

@property (weak) id < WallpaperRequestOperationDelegate > delegate;

- (id)initWithURL:(NSURL *)url;

@end


@protocol WallpaperRequestOperationDelegate

- (void)wallpaperRequestOperationDidComplete:(WallpaperRequestOperation *)operation;

@end
