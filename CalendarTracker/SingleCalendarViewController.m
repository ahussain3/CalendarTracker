//
//  SingleCalendarViewController.m
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import "SingleCalendarViewController.h"
#import "ClassEventCell.h"
#import "EventKitData.h"
#import "TSCalendarSegment.h"
#import "TotalHoursViewController.h"
@interface SingleCalendarViewController ()

@end

@implementation SingleCalendarViewController
@synthesize calSegment = _calSegment,eventKit = _eventKit,eventArray = _eventArray,dateArray = _dateArray,datePeriodLabel = _datePeriodLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!_eventKit)
    _eventKit = [[EventKitData alloc]init];

    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    /*
     Create a date components to represent the number of days to subtract
     from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so
     subtract 1 from the number
     of days to subtract from the date in question.  (If today's Sunday,
     subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    /* Substract [gregorian firstWeekday] to handle first day of the week being something else than Sunday */
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    /*
     Optional step:
     beginningOfWeek now has the same hour, minute, and second as the
     original date (today).
     To normalize to midnight, extract the year, month, and day components
     and create a new date from those components.
     */
    NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate: beginningOfWeek];
    NSDate * startDate = [gregorian dateFromComponents: components];
    NSTimeInterval interval = 60*60*24;
    startDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    [self updateArraysWithStartDate:startDate];
    
    self.navigationItem.title = self.calSegment.title;

    // Do any additional setup after loading the view from its nib.
    
}

-(void)updateArraysWithStartDate:(NSDate*)startDate
{
    _eventArray = [_eventKit eventsGroupedByDayForCalendar:self.calSegment];
    _dateArray = [[_eventArray allKeys]sortedArrayUsingSelector:@selector(compare:)];
    [[self tableView] reloadData];
    _datePeriodLabel.text = self.previousController.datePeriodLabel.text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * CellIdentifier = @"ClassEventCell";
     ClassEventCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray * topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ClassEventCell" owner:self options:nil];
        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[ClassEventCell class]]) {
                cell = (ClassEventCell *)currentObject;
                break;
            }
        }
    }
   EKEvent * event = [[_eventArray objectForKey:[_dateArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    
    cell.title.text = event.title;
    cell.locationLabel.text = event.location;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"h:mma"];
    cell.beginLabel.text = [[dateFormatter stringFromDate:event.startDate] lowercaseString];
    cell.endLabel.text = [[dateFormatter stringFromDate:event.endDate] lowercaseString];
    UIColor * color = [[UIColor alloc]initWithCGColor:event.calendar.CGColor];
    cell.colorView.backgroundColor = color;
    cell.beginLabel.textColor = color;
    cell.endLabel.textColor = color;
    NSTimeInterval distanceBetweenDates = [event.endDate timeIntervalSinceDate:event.startDate];
    double hoursBetweenDates = distanceBetweenDates /3600.0;
    cell.durationLabel.text = [NSString stringWithFormat:@"%.1fh",hoursBetweenDates];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_eventArray objectForKey:[_dateArray objectAtIndex:section] ] count];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dateArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    double totalHour = 0.0;
    for (EKEvent* e in [_eventArray objectForKey:[_dateArray objectAtIndex:section]])
    {
        NSTimeInterval distanceBetweenDates = [e.endDate timeIntervalSinceDate:e.startDate];
        double hoursBetweenDates = distanceBetweenDates /3600.0;
        totalHour+= hoursBetweenDates;
    }
    NSDate * str = [_dateArray objectAtIndex:section];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    //dateFormatter.locale = [NSLocale loc]
    [dateFormatter setDateFormat:@"EEEE MMM d"];
    return [NSString stringWithFormat:@"%@ %.1fh",[dateFormatter stringFromDate:str],totalHour];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)forwardButton:(id)sender {
    [self.previousController forwardButton:sender];
    self.calSegment =[(TotalHoursViewController*)(self.previousController)getNewCaldendar];
    [self updateArraysWithStartDate: self.previousController.currentStartDate];
}

- (IBAction)backButton:(id)sender {
    [self.previousController backwardButton:sender];
    self.calSegment =[(TotalHoursViewController*)(self.previousController)getNewCaldendar];
    [self updateArraysWithStartDate: self.previousController.currentStartDate];


}
@end
