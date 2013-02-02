//
//  TotalHoursViewController.m
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import "TotalHoursViewController.h"
#import "TotalHourCell.h"
#import "TSCalendarSegment.h"
#import "EventKitData.h"
#import "GraphViewController.h"
#import "SingleCalendarViewController.h"
@interface TotalHoursViewController ()

@end

@implementation TotalHoursViewController
@synthesize calendars = _calendars,currentEndDate = _currentEndDate,currentStartDate = _currentStartDate, store = _store,tableView,datePeriodLabel = _datePeriodLabel,totalHours = _totalHours;

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
    self.navigationItem.title = @"Calendars";
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Graph" style:UIBarButtonItemStyleBordered target:self action:@selector(graphButtonPressed:)];
    
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
    [self updateTableWithStartDate:startDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateTableWithStartDate:(NSDate*)startDate {
    NSTimeInterval interval = 60*60*24*7;
    NSDate *endDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    _currentStartDate = [startDate copy];
    _currentEndDate = [endDate copy];
    if(!_store){
    _store= [[EventKitData alloc] init];}
    _calendars = [_store eventsGroupedByCalendarforStartDate:startDate andEndDate:endDate];
    
[self.tableView reloadData];
    
  
    interval = -60*60*24;
    endDate = [NSDate dateWithTimeInterval:interval sinceDate:endDate];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM d"];
    _datePeriodLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:startDate],[dateFormatter stringFromDate:endDate]];
    _totalHours = 0;
    for (TSCalendarSegment *t in _calendars) {
        _totalHours += [t.totalHours intValue];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString * CellIdentifier = @"TotalHourCell";
    TotalHourCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray * topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"TotalHourCell" owner:self options:nil];
        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[TotalHourCell class]]) {
                cell = (TotalHourCell *)currentObject;
                break;
            }
        }
    }
    TSCalendarSegment * ts = ((TSCalendarSegment*)([_calendars objectAtIndex:[indexPath row]]));
    
    cell.titleLabel.text = ts.title;
    int events = ts.numberOfEvents;
    NSMutableString* tense = [[NSMutableString alloc]initWithString:@"event"];
    
    if(events >1)
        [tense appendString:@"s"];
    cell.numberOfEventsLabel.text = [NSString stringWithFormat:@"%d %@",events,tense];
    cell.imageView.backgroundColor = ts.color;
    cell.totalHourLabel.text = [NSString stringWithFormat:@"%@h",ts.totalHours];
    cell.colorView.backgroundColor = ts.color;
    cell.percentLabel.text = [NSString stringWithFormat:@"%d%%", [ts.totalHours intValue]*100/(_totalHours)];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_calendars count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleCalendarViewController * svc = [[SingleCalendarViewController alloc]init];
    svc.calSegment = ((TSCalendarSegment*)([_calendars objectAtIndex:[indexPath row]]));
    self.identifier = svc.calSegment.calendar.calendarIdentifier;
    
    svc.previousController = self;
    [self.navigationController pushViewController:svc animated:YES];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)forwardButton:(id)sender {
    NSTimeInterval interval = 60*60*24*7;
    NSDate * newStartDate = [NSDate dateWithTimeInterval:interval sinceDate:_currentStartDate];
    [self updateTableWithStartDate:newStartDate];
}
- (IBAction)backwardButton:(id)sender {
    NSTimeInterval interval = -60*60*24*7;
    NSDate * newStartDate = [NSDate dateWithTimeInterval:interval sinceDate:_currentStartDate];
    [self updateTableWithStartDate:newStartDate];
}
-(IBAction)graphButtonPressed:(id)sender
{
    GraphViewController* newController = [[GraphViewController alloc]init];
    newController.previousController = self;
    [self.navigationController pushViewController:newController animated:YES];
}

-(NSDictionary *)valuesForBars
{
#define INDEX_COLOR 0
#define INDEX_HOURS 1
#define INDEX_PERCENT 2
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    for (TSCalendarSegment*s in _calendars) {
        
        NSArray * array = [NSArray arrayWithObjects:s.color,s.totalHours,[NSNumber numberWithInt:[s.totalHours intValue]*100.0/(_totalHours)], nil];
        [dictionary setObject:array forKey:s.title];
    }
    return dictionary;
}

-(TSCalendarSegment*) getNewCaldendar
{
   for(TSCalendarSegment* t in self.calendars)
   {
       NSLog(@"%@",t.calendar);
       if([t.calendar.calendarIdentifier isEqualToString: self.identifier])
           return t;
   }
    return nil;
}

@end
