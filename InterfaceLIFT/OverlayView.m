//
//  OverlayView.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor lightGrayColor] set];
	NSRectFill([self bounds]);
}

@end
