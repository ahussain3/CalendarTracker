//
//  EventKitData.m
//  PullEventKitData
//
//  Created by Awais Hussain on 1/25/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "EventKitData.h"
#import "TSCalendarSegment.h"

@implementation EventKitData
@synthesize store;


-(id)init
{
    self = [super init];
    if(self)
    {
        store = [[EKEventStore alloc] init];
        if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            // iOS 6 and later
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                
                if (granted) {
                    NSLog(@"Events calendar accessed");
                    //---- codes here when user allow your app to access theirs' calendar.
                    
                } else
                {
                    NSLog(@"Failed to access events calendar");
                    //----- codes here when user NOT allow your app to access the calendar.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar access failed" message:@"We can't do much if access to phone calendar is not granted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [alert show];
                }
            }];
            
        }
        

    }
    return self;

}

// Returns array of EKEvent objects
// calendars is an NSArray of EKCalendar objects
- (NSArray *) eventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    // internet code ask user for permission
    // retrieve all calendars
    NSArray *calendars = [store calendarsForEntityType:EKEntityTypeEvent];
    
    // This array will store all the events from all calendars.
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    
    for (EKCalendar *calendar in calendars) {
        
        // Print calendar information
        //NSLog(@"Calendar Title: %@", calendar.title);
        
        // Get events for calendar
        NSArray *calendarArray = [NSArray arrayWithObject:calendar];
        NSPredicate *searchPredicate = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
        
        // create temporary array to store events for THIS calendar
        NSMutableArray *eventsForCalendar = [[store eventsMatchingPredicate:searchPredicate]mutableCopy];
        //NSLog(@"No. of events found for '%@' calendar: %i", calendar.title, [eventArray count]);
        NSMutableArray * temp = [[NSMutableArray alloc]init];
        
        // remove all day events
        for (EKEvent *event in eventsForCalendar) {
            if (event.allDay) {
            
                [temp addObject:event];
            }
        }
        
        [eventsForCalendar removeObjectsInArray:temp];
        
        
        
        // merge with main storage array
        [eventArray addObjectsFromArray:eventsForCalendar];
    }
    
    // sort events in order of start date.
    [eventArray sortUsingSelector:@selector(compareStartDateWithEvent:)];
    
    // print events in log file
    // NSLog(@"Full List of Sorted Events:");
    //for (EKEvent* event in eventArray) {
    //    NSLog(@"Event Calendar: %@", event.calendar.title);
    //    NSLog(@"Event Title: %@", event.title);
    //    NSLog(@"Event Location: %@", event.location);
    //    NSLog(@"Event Start Date: %@", event.startDate);
    //    NSLog(@"Event End Date: %@", event.endDate);
    //}
    
    return eventArray;
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (NSDictionary *) eventsGroupedByDayforStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NSArray *allEvents = [self eventsForStartDate:startDate endDate:endDate];
    
    NSMutableDictionary *sections = [[NSMutableDictionary alloc]init];
    for (EKEvent *event in allEvents)
    {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event.startDate];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [[NSMutableArray alloc] init];
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
    }
    
    // Create a sorted list of days
    // NSArray *unsortedDays = [sections allKeys];
    // NSArray *sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    // print what we have to check
   // NSLog(@"Number of entries in full dict: %i", [sections count]);
    //NSArray *allKeys = [sections allKeys];
    //NSLog(@"Keys in dictionary (days): %@", allKeys);

    /*for (NSArray *n in [sections allValues]) {
        NSLog(@"\n\n\nNEW GROUPS\n\n\n");
        for (EKEvent * event in n) {
            NSLog(@"Event Calendar: %@", event.calendar.title);
            NSLog(@"Event Title: %@", event.title);
            NSLog(@"Event Location: %@", event.location);
            NSLog(@"Event Start Date: %@", event.startDate);
            NSLog(@"Event End Date: %@", event.endDate);
            
        }
    }
    */
    return sections;
}

- (NSArray *) eventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate andCalendar:(EKCalendar *)calendar {
    //NSLog(@"Enter Get Events for Calendar function");
    
    
    // retrieve calendar - is a parameter in the function
    
    // Print calendar information
    //NSLog(@"Calendar Title: %@", calendar.title);
    
    // Get events for calendar
    NSArray *calendarArray = [[NSArray alloc]initWithObjects:calendar, nil];
    NSPredicate *searchPredicate = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
    
    NSMutableArray *eventArray = [[store eventsMatchingPredicate:searchPredicate]mutableCopy];
    //NSLog(@"No. of events found: %i", [eventArray count]);
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    // print events in log file
    // remove all day events
    for (EKEvent *event in eventArray) {
        if (event.allDay) {
            [temp addObject:event];
        }
    }
    
    [eventArray removeObjectsInArray:temp];
    
    return eventArray;
}


- (NSArray *) eventsGroupedByCalendarforStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    // Get eventstore object -> required later when we use calendar identifier to locate a calendar.
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    // internet code ask user for permission
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            if (granted) {
                NSLog(@"Events calendar accessed");
                //---- codes here when user allow your app to access theirs' calendar.
                
            } else
            {
                NSLog(@"Failed to access events calendar");
                //----- codes here when user NOT allow your app to access the calendar.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar access failed" message:@"We can't do much if access to phone calendar is not granted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
    
    NSArray *allEvents = [self eventsForStartDate:startDate endDate:endDate];
    
    // Dictionary grouping events by calendar
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    
    for (EKEvent *event in allEvents)
    {
        // Get the events calendar
        EKCalendar *calendar = event.calendar;
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsForThisCalendar = [sections objectForKey:calendar.calendarIdentifier];
        if (eventsForThisCalendar == nil) {
            eventsForThisCalendar = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sections setObject:eventsForThisCalendar forKey:calendar.calendarIdentifier];
        }
        
        // Add the event to the list for this day
        [eventsForThisCalendar addObject:event];
    }
    
    // Convert the data from a dictionary into an array of TSCalendarSegment objects.
    
    // Array of TSCalendarSegment objects
    NSMutableArray *calendarSegments = [[NSMutableArray alloc] init];
    
    NSArray *calendarIdentfiers = [sections allKeys];
    for (NSString *identifier in calendarIdentfiers) {
        TSCalendarSegment *calSegment = [[TSCalendarSegment alloc] initWithStartDate:startDate andEndDate:endDate];
        
        EKCalendar *calendar = [eventStore calendarWithIdentifier:identifier];
        calSegment.calendar = calendar;
        
        NSArray *events = [sections objectForKey:identifier];
        calSegment.events = events;
        [calendarSegments addObject:calSegment];
    }
    
    // print for diagnostic purposes
    //NSLog(@"Calendar Identifiers: %@", calendarIdentfiers);
    //NSLog(@"Calendar Segments Array: %@", calendarSegments);
    
    return calendarSegments;
}

- (NSDictionary *) eventsGroupedByDayForCalendar:(TSCalendarSegment *)calSegment {
    
    NSDictionary *eventsGroupedByDay = [self groupEventsByDay:calSegment.events];
    
    return eventsGroupedByDay;
}

- (NSDictionary *) groupEventsByDay:(NSArray *)events {
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    
    for (EKEvent *event in events)
    {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event.startDate];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
    }
    
    return sections;
}


@end


