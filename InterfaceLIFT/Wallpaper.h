//
//  Wallpaper.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

@interface Wallpaper : NSObject

@property (copy) NSString *title;
@property (copy) NSString *identifier;

@property (strong) NSURL *previewURL;
@property (readonly) NSURL *downloadURL;

@property (strong) NSImage *thumbnail;

@end
