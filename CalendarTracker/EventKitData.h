//
//  EventKitData.h
//  PullEventKitData
//
//  Created by Awais Hussain on 1/25/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
@class TSCalendarSegment;
@interface EventKitData : NSObject

// Returns array of all EKEvent objects
- (NSArray *) eventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

// Returns an NSDictionary of events grouped by start day. The keys of the dictionary are NSDate objects.
- (NSDictionary *) eventsGroupedByDayforStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

// Returns array of EKEvents for a given calendar
- (NSArray *) eventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate andCalendar:(EKCalendar *)calendar;


// Returns NSArray of TSCalendarSegment objects which each contain information for events and the calendar they fall under, thus grouping the events by calendar.
- (NSArray *) eventsGroupedByCalendarforStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

// Nice utility function which comes in useful when you want to produce tables sectioned by day. This does not pay attention to calendars.
- (NSDictionary *) groupEventsByDay:(NSArray *)events;

- (NSDictionary *) eventsGroupedByDayForCalendar:(TSCalendarSegment *)calSegment;



@property (nonatomic,strong) EKEventStore* store;

@end

