//
//  GraphViewController.h
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColumnGraphView,TotalHoursViewController;
@interface GraphViewController : UIViewController
@property (weak, nonatomic) IBOutlet ColumnGraphView *graphView;
@property(weak, nonatomic)TotalHoursViewController* previousController;
- (IBAction)backwardButton:(id)sender;
- (IBAction)forwardButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *datePeriodLabel;
@end
