//
//  SingleCalendarViewController.h
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TSCalendarSegment,EventKitData,TotalHoursViewController;
@interface SingleCalendarViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) TSCalendarSegment* calSegment;
@property (nonatomic,strong) EventKitData * eventKit;
@property (nonatomic,strong) NSDictionary * eventArray;
@property (nonatomic,strong) NSArray * dateArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)forwardButton:(id)sender;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *datePeriodLabel;
@property (weak,nonatomic)TotalHoursViewController *previousController;
@end
