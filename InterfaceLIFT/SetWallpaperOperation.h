//
//  SetWallpaperOperation.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "ConcurrentOperation.h"

@class Wallpaper;
@protocol SetWallpaperOperationDelegate;

@interface SetWallpaperOperation : ConcurrentOperation < NSURLDownloadDelegate >

@property (readonly) Wallpaper *wallpaper;

@property (weak) id < SetWallpaperOperationDelegate > delegate;

- (id)initWithWallpaper:(Wallpaper *)wallpaper;

@end


@protocol SetWallpaperOperationDelegate

- (void)setWallpaperOperationDidStartDownload:(SetWallpaperOperation *)operation;
- (void)setWallpaperOperationDidFinishDownload:(SetWallpaperOperation *)operation;

@end
