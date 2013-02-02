//
//  EventViewController.h
//  CalendarTracker
//
//  Created by Timothy Chong on 1/25/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EKEventStore;
@interface EventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *dateBar;
@property (strong, nonatomic) NSDictionary* eventsArray;
@property (strong, nonatomic) NSArray * titlesArray;
@property (nonatomic,strong) EKEventStore* store;
@property (weak, nonatomic) IBOutlet UILabel *datePeriodLabel;
@property(strong,nonatomic)NSDate * currentStartDate;
@property(strong,nonatomic)NSDate * currentEndDate;
- (IBAction)backardButton:(id)sender;
- (IBAction)forwardButton:(id)sender;
@end
