//
//  ImageCell.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

@class GalleryView;

@interface ImageCell : NSView

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, assign) BOOL isNew;

@property (nonatomic, weak) GalleryView *galleryView;

- (void)showOverlay;
- (void)hideOverlay;

@end
