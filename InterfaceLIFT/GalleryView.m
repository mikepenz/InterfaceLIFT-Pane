//
//  GalleryView.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "GalleryView.h"

#define COLS 3

#define MARGIN_V 20.0f
#define MARGIN_H 31.0f
#define BOX_W 168.0f
#define BOX_H 105.0f
#define MBW (MARGIN_H + BOX_W)
#define MBH (MARGIN_V + BOX_H)

@implementation GalleryView {
	NSMutableArray *_cells;
}

@synthesize footerView = _footerView, delegate = _delegate;

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		[self setWantsLayer:YES];
		
		self.layer.backgroundColor = CGColorGetConstantColor(kCGColorWhite);
		
		_cells = [NSMutableArray new];
	}
	return self;
}

- (void)dealloc {
	[_footerView release];
	[_cells release];
	
	[super dealloc];
}

- (BOOL)isFlipped {
	return YES;
}

- (void)insertImagesAtIndices:(NSIndexSet *)indices {
	[indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		
		ImageCell *imageCell = [[ImageCell alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, BOX_W, BOX_H)];
		imageCell.galleryView = self;
		imageCell.image = [self.delegate galleryView:self imageAtIndex:idx];
		imageCell.isNew = [self.delegate galleryView:self isImageNewAtIndex:idx];
		imageCell.toolTip = [self.delegate galleryView:self titleForImageAtIndex:idx];
		
		[_cells addObject:imageCell];
		[imageCell release];
		
		[self addSubview:imageCell];
		
	}];
	
	if (self.footerView && ![self.footerView superview]) {
		[self addSubview:self.footerView];
	}
	
	[self layoutCells];
}

- (void)clickedCell:(ImageCell *)cell {
	[self.delegate galleryView:self didSelectCellAtIndex:[_cells indexOfObject:cell]];
}

- (ImageCell *)imageCellAtIndex:(NSUInteger)index {
	return [_cells objectAtIndex:index];
}

- (void)reloadImageCellAtIndex:(NSUInteger)index {
	ImageCell *cell = [self imageCellAtIndex:index];
	cell.image = [self.delegate galleryView:self imageAtIndex:index];
	cell.toolTip = [self.delegate galleryView:self titleForImageAtIndex:index];
}

- (NSUInteger)numberOfRows {
	NSUInteger images = [self.delegate numberOfImagesInGalleryView:self];
	
	return ceilf(images / (CGFloat) COLS);
}

- (void)layoutCells {
	CGFloat rowHeight = [self numberOfRows] * MBH;
	CGFloat galleryHeight = rowHeight;
	
	if (self.footerView) {
		galleryHeight += NSHeight(self.footerView.bounds);
		galleryHeight += MARGIN_V * 2;
	}
	
	[self setFrameSize:NSMakeSize(NSWidth([self frame]), galleryHeight)];
	
	NSUInteger n = 0;
	
	for (ImageCell *cell in _cells) {
		NSUInteger row = n / COLS;
		NSUInteger col = n % COLS;
		
		cell.frame = NSMakeRect(MARGIN_H + col * MBW, MARGIN_V + row * MBH, BOX_W, BOX_H);
		
		n++;
	}
	
	CGFloat x = ceilf((NSWidth([self bounds]) - NSWidth([self.footerView bounds])) / 2);
	
	[self.footerView setFrameOrigin:NSMakePoint(x, rowHeight + MARGIN_V)];
}

@end
