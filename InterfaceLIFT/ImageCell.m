//
//  ImageCell.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "ImageCell.h"

#import "GalleryView.h"
#import "OverlayView.h"

@interface GalleryView (Events)

- (void)clickedCell:(ImageCell *)cell;

@end


@implementation ImageCell {
	NSProgressIndicator *_indicator;
	NSImageView *_imageView;
	NSImageView *_badgeView;
	OverlayView *_overlayView;
}

#define BADGE_SIDE 20.0f

@synthesize isNew = _isNew, galleryView = _galleryView;

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		[self addSubview:[self indicator]];
	}
	return self;
}

- (void)dealloc {
	[_indicator release];
	[_imageView release];
	[_badgeView release];
	[_overlayView release];
	
	[super dealloc];
}

- (NSProgressIndicator *)indicator {
	if (!_indicator) {
		_indicator = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
		_indicator.indeterminate = YES;
		_indicator.style = NSProgressIndicatorSpinningStyle;
		
		[_indicator sizeToFit];
		[_indicator startAnimation:nil];
	}
	
	return _indicator;
}

- (OverlayView *)overlayView {
	if (!_overlayView) {
		_overlayView = [[OverlayView alloc] initWithFrame:[self bounds]];
		_overlayView.alphaValue = 0.0f;
	}
	
	return _overlayView;
}

- (void)viewDidMoveToSuperview {
	[self layoutSubviews];
}

- (void)layoutSubviews {
	CGFloat w = NSWidth([_indicator bounds]);
	CGFloat h = NSHeight([_indicator bounds]);
	
	CGFloat x = (int) NSMidX([self bounds]);
	CGFloat y = (int) NSMidY([self bounds]);
	
	_indicator.frame = NSMakeRect(x-w/2, y-w/2, w, h);
}

- (NSImage *)image {
	return _imageView.image;
}

- (void)setImage:(NSImage *)image {
	if (!image)
		return;
	
	if (!_imageView) {
		[_indicator removeFromSuperview];
		
		_imageView = [[NSImageView alloc] initWithFrame:[self bounds]];
		_imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
		
		[self addSubview:_imageView];
	}
	
	_imageView.image = image;
	
	if (_isNew) {
		if (!_badgeView) {
			_badgeView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth([self bounds])-BADGE_SIDE, NSHeight([self bounds])-BADGE_SIDE, BADGE_SIDE, BADGE_SIDE)];
			_badgeView.image = [[NSBundle bundleWithIdentifier:@"com.MattRajca.InterfaceLIFT"] imageForResource:@"Badge"];
			
			[self addSubview:_badgeView];
		}
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (!self.image || _overlayView.superview)
		return;
	
	self.isNew = NO;
	
	[_badgeView removeFromSuperview];
	
	[self.galleryView clickedCell:self];
}

- (void)showOverlay {
	[self addSubview:[self overlayView]];
	[self addSubview:_indicator positioned:NSWindowAbove relativeTo:_overlayView];
	
	[[_overlayView animator] setAlphaValue:0.8f];
}

- (void)hideOverlay {
	[_indicator removeFromSuperview];
	
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		[[_overlayView animator] setAlphaValue:0.0f];
	} completionHandler:^{
		[_overlayView removeFromSuperview];
	}];
}

@end
