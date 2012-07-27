//
//  ConcurrentOperation.m
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

#import "ConcurrentOperation.h"

@implementation ConcurrentOperation {
	BOOL _executing, _finished;
}

@synthesize executing = _executing, finished = _finished;

- (BOOL)isConcurrent {
	return YES;
}

- (void)setExecuting:(BOOL)executing {
	if (_executing != executing) {
		[self willChangeValueForKey:@"isExecuting"];
		_executing = executing;
		[self didChangeValueForKey:@"isExecuting"];
	}
}

- (void)setFinished:(BOOL)finished {
	if (_finished != finished) {
		[self willChangeValueForKey:@"isFinished"];
		_finished = finished;
		[self didChangeValueForKey:@"isFinished"];
	}
}

- (void)startOnMainThread { }

- (void)start {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}
	
	[self startOnMainThread];
}

@end
