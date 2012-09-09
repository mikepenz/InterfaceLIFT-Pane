//
//  InterfaceLIFT.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "GalleryView.h"
#import "SetWallpaperOperation.h"

@interface InterfaceLIFT : NSPreferencePane < GalleryViewDelegate, SetWallpaperOperationDelegate >

@property (nonatomic, weak) IBOutlet GalleryView *galleryView;

- (void)loadNextPageOfWallpapers;

@end
