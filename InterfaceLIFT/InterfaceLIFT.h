//
//  InterfaceLIFT.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "GalleryView.h"
#import "SetWallpaperOperation.h"
#import "WallpaperRequestOperation.h"

@interface InterfaceLIFT : NSPreferencePane < GalleryViewDelegate, SetWallpaperOperationDelegate, WallpaperRequestOperationDelegate >

@property (nonatomic, weak) IBOutlet GalleryView *galleryView;

- (void)loadNextPageOfWallpapers;

@end
