//
//  ThreadingExamplesViewController.h
//  TestApp
//
//  Created by Kyle Carruthers on 2015-01-02.
//  Copyright (c) 2015 Kyle Carruthers. All rights reserved.
//

#import <UIKit/UIKit.h>

// Adds 'threads' to a tableView
// The table will display the thread number and progress towards completion
// Threads use a timer to tick in the background and when complete they stop ticking
// Threads are added on the background thread 
@interface ThreadingExamplesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(IBAction)addThread:(id)sender;

@end
