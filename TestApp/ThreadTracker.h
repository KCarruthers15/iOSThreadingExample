//
//  ThreadTracker.h
//  TestApp
//
//  Created by Kyle Carruthers on 2015-01-02.
//  Copyright (c) 2015 Kyle Carruthers. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keeps track of each 'Thread'
// Threads will update on a timer
// Each time a timer ticks a tick will be added to currentTicks
// Progress is determined from the currentTicks and threadNum
// When the currentTicks equals the threadNum the thread is 'complete'
@interface ThreadTracker : NSObject

@property uint threadNum;
@property (getter = isComplete) bool complete;
@property float progress;
@property float currentTicks;
@property dispatch_source_t threadTimer;

@end
