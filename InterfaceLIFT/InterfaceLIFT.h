//
//  InterfaceLIFT.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "GalleryView.h"

@interface InterfaceLIFT : NSPreferencePane < GalleryViewDelegate >

@property (nonatomic, weak) IBOutlet GalleryView *galleryView;

- (void)loadNextPageOfWallpapers;

@end
