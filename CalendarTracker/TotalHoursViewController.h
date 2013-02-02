//
//  TotalHoursViewController.h
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColumnGraphView.h"
@class EventKitData,TSCalendarSegment;
@interface TotalHoursViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ColumnGraphViewDataSource>
@property (nonatomic,strong) NSArray * calendars;
@property(strong,nonatomic)NSDate * currentStartDate;
@property(strong,nonatomic)NSDate * currentEndDate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backwardButton:(id)sender;
@property (nonatomic,strong) EventKitData* store;
@property (weak, nonatomic) IBOutlet UILabel *datePeriodLabel;
@property (assign,nonatomic) int totalHours;
@property (strong,nonatomic)NSString * identifier;
- (IBAction)forwardButton:(id)sender;
-(TSCalendarSegment*) getNewCaldendar;

@end
