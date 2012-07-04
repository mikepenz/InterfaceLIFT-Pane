//
//  GalleryView.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "ImageCell.h"

@protocol GalleryViewDelegate;

@interface GalleryView : NSView

@property (nonatomic, strong) NSView *footerView;

@property (nonatomic, weak) IBOutlet id < GalleryViewDelegate > delegate;

- (void)insertImagesAtIndices:(NSIndexSet *)indices;

- (ImageCell *)imageCellAtIndex:(NSUInteger)index;

- (void)reloadImageCellAtIndex:(NSUInteger)index;

@end


@protocol GalleryViewDelegate <NSObject>

- (NSUInteger)numberOfImagesInGalleryView:(GalleryView *)view;
- (NSImage *)galleryView:(GalleryView *)view imageAtIndex:(NSUInteger)index;
- (BOOL)galleryView:(GalleryView *)view isImageNewAtIndex:(NSUInteger)index;
- (NSString *)galleryView:(GalleryView *)view titleForImageAtIndex:(NSUInteger)index;

- (void)galleryView:(GalleryView *)view didSelectCellAtIndex:(NSUInteger)index;

@end
