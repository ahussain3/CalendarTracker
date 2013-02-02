//
//  EventViewController.m
//  CalendarTracker
//
//  Created by Timothy Chong on 1/25/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import "EventViewController.h"
#import "EventCell.h"
#import "EventKitData.h"
#import "TotalHoursViewController.h"
@interface EventViewController ()

@end

@implementation EventViewController

@synthesize eventsArray = _eventsArray,titlesArray=_titlesArray,store = _store,tableView = _tableView,datePeriodLabel = _datePeriodLabel, currentStartDate = _currentStartDate,currentEndDate = _currentEndDate;
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
    self.navigationItem.title = @"All Events";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Calendar" style:UIBarButtonItemStyleBordered target:self action:@selector(goToCalendar:)];
    
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
    [self updateWtihStartDate:startDate];
    // Do any additional setup after loading the view from its nib.

}
-(void) updateWtihStartDate:(NSDate*) startDate
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
    NSTimeInterval interval = 60*60*24*7;
    NSDate *endDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    _currentStartDate = [startDate copy];
    _currentEndDate = [endDate copy];
    [self updateArrayWithStartDate:startDate endDate:endDate];

    interval = -60*60*24;
    endDate = [NSDate dateWithTimeInterval:interval sinceDate:endDate];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM d"];
    _datePeriodLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:startDate],[dateFormatter stringFromDate:endDate]];
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.contentSize = CGSizeMake(320, self.tableView.contentSize.height+50);
}

-(void) updateArrayWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    EventKitData *eventKitData = [[EventKitData alloc] init];
    _store = eventKitData.store;
    _eventsArray = [eventKitData eventsGroupedByDayforStartDate:startDate andEndDate:endDate];
    _titlesArray = [[_eventsArray allKeys]sortedArrayUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"EventCell";
    EventCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray * topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"EventCell" owner:self options:nil];
        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[EventCell class]]) {
                cell = (EventCell *)currentObject;
                break;
            }
        }
    }

    EKEvent* event = [[_eventsArray objectForKey:[_titlesArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    cell.titleLabel.text = event.title;
    
    
    cell.locationLabel.text = event.location;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
     [dateFormatter setDateFormat:@"h:mma"];
    cell.beginTimeLabel.text = [[dateFormatter stringFromDate:event.startDate] lowercaseString];
    cell.endTimeLabel.text = [[dateFormatter stringFromDate:event.endDate] lowercaseString];
    UIColor * color = [[UIColor alloc]initWithCGColor:event.calendar.CGColor];
    
    cell.colorView.backgroundColor = color;
    cell.beginTimeLabel.textColor = color;
    cell.endTimeLabel.textColor = color;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[_eventsArray objectForKey:[_titlesArray objectAtIndex:section]]count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSDate * str = [_titlesArray objectAtIndex:section];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    //dateFormatter.locale = [NSLocale loc]
    [dateFormatter setDateFormat:@"EEEE MMM d"];
    return [dateFormatter stringFromDate:str];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_titlesArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)backardButton:(id)sender {
    NSTimeInterval interval = -60*60*24*7;
    NSDate * newStartDate = [NSDate dateWithTimeInterval:interval sinceDate:_currentStartDate];
    [self updateWtihStartDate:newStartDate];
    
}

- (IBAction)forwardButton:(id)sender {
    NSTimeInterval interval = 60*60*24*7;
    NSDate * newStartDate = [NSDate dateWithTimeInterval:interval sinceDate:_currentStartDate];
    [self updateWtihStartDate:newStartDate];
}
-(IBAction)goToCalendar:(id)sender
{
    TotalHoursViewController * thvc =[[TotalHoursViewController alloc]init];
    [self.navigationController pushViewController:thvc animated:YES];
}
@end
