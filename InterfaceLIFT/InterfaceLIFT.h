//
//  InterfaceLIFT.h
//  InterfaceLIFT
//
//  Copyright (c) 2013 Matt Rajca. All rights reserved.
//

#import "GalleryView.h"
#import "SetWallpaperOperation.h"

@interface InterfaceLIFT : NSPreferencePane < GalleryViewDelegate, SetWallpaperOperationDelegate>

@property (nonatomic, weak) IBOutlet GalleryView *galleryView;

- (void)loadNextPageOfWallpapers;

@end
