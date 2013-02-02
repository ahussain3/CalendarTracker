//
//  TotalHourCell.h
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TotalHourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *totalHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfEventsLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@end
