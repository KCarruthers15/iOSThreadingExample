//
//  ThreadingExamplesViewController.m
//  TestApp
//
//  Created by Kyle Carruthers on 2015-01-02.
//  Copyright (c) 2015 Kyle Carruthers. All rights reserved.
//

#import "ThreadingExamplesViewController.h"
#import "ThreadTracker.h"

@interface ThreadingExamplesViewController ()

@property (strong, nonatomic) NSMutableArray *threads;
@property (strong, nonatomic) NSLock *arrayLock;
@property const float timerSpeed;

@end

@implementation ThreadingExamplesViewController

#pragma mark - Default Functionality

- (NSMutableArray *)threads
{
    if (!_threads)
        _threads = [[NSMutableArray alloc] init];
    
    return _threads;
}

// Lock for the array of threads - should be used on reads and writes
-(NSLock *)arrayLock
{
    if (!_arrayLock)
        _arrayLock = [[NSLock alloc] init];
    
    return _arrayLock;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // How fast the background timer updates the UI (in seconds)
    self.timerSpeed = 0.5;
}

#pragma mark - Functionality

// Adds a new thread to the table
-(IBAction)addThread:(id)sender
{
    [self.arrayLock lock];
    int count = [self.threads count];
    count++;
    
    ThreadTracker *thread = [ThreadTracker new];
    thread.threadNum = count;
    thread.progress = 0;
    thread.complete = NO;
    thread.currentTicks = 0;
    
    [self.threads addObject:thread];
    [self.arrayLock unlock];
    
    [self.tableView reloadData];
    
    [self startNewBackroundTask:count];
}

#pragma mark - TableView Implementation

// Get the number of threads that will be in the table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.arrayLock lock];
    int count = [self.threads count];
    [self.arrayLock unlock];
    
    return count;
}

// Update the tableView with the data
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    
    [self.arrayLock lock];
    
    ThreadTracker *currentThread = self.threads[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d - %.02f%%", currentThread.threadNum, currentThread.progress];
    
    [self.arrayLock unlock];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //[self startNewMainThreadTask:^{}];
}

#pragma mark - Task Helper Methods

// Start a new background task for the thread to run on
-(void)startNewBackroundTask:(int)threadNum
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue,
    ^{
        [self.arrayLock lock];
        
        ThreadTracker *thread = self.threads[threadNum-1];
        
        // Put the thread on a timer so it can update every ## of seconds (based on self.timerSpeed)
        thread.threadTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(thread.threadTimer, DISPATCH_TIME_NOW, self.timerSpeed * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(thread.threadTimer,
        ^{
            [self updateUI:threadNum];
        });
        
        dispatch_resume(thread.threadTimer);
        
        [self.arrayLock unlock];
    });
}

// Dispatch to update the UI thread when a timer updates
-(void)updateUI:(int)threadNum
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self.arrayLock lock];
        
        ThreadTracker *thread = self.threads[threadNum-1];
        
        // Update the thread progress if it is not complete yet
        if (thread.currentTicks <  thread.threadNum)
        {
            thread.currentTicks += self.timerSpeed;
            thread.progress = (thread.currentTicks / thread.threadNum) * 100;
        }
        
        // Make sure that the thread displays 1.0 when complete
        if (thread.currentTicks >= thread.threadNum)
        {
            thread.progress = 1.0;
            
            // Cancel the timer since the thread is done what it was doing
            dispatch_source_cancel(thread.threadTimer);
        }
        
        [self.arrayLock unlock];
        
        // Get the table to update with the new thread data
        [self.tableView reloadData];
    });
}

// Run a function on the main thread (Not currently used. Example of how to do a block in a function signature)
-(void)startNewMainThreadTask:(void(^)(void))blockToRun
{
    dispatch_async(dispatch_get_main_queue(), ^{
        blockToRun();
    });
    
}

@end
