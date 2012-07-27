//
//  ConcurrentOperation.h
//  InterfaceLIFT
//
//  Copyright (c) 2012 Matt Rajca. All rights reserved.
//

@interface ConcurrentOperation : NSOperation

@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isFinished) BOOL finished;

- (void)startOnMainThread;

@end
