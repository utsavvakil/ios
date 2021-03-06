//
//  OHMReminderManager.m
//  ohmage_ios
//
//  Created by Charles Forkish on 5/12/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "OHMReminderManager.h"
#import "OHMReminder.h"
#import "OHMLocationManager.h"
#import "OHMReminderLocation.h"
#import "OHMSurvey.h"
#import "OHMUser.h"

@implementation OHMReminderManager

+ (instancetype)sharedReminderManager
{
    static OHMReminderManager *_sharedReminderManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedReminderManager = [[self alloc] initPrivate];
    });
    
    return _sharedReminderManager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[OHMReminderManager sharedReminderManager]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        [self debugPrintAllNotifications];
    }
    return self;
}

- (void)unscheduleNotificationsForReminder:(OHMReminder *)reminder
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *existingNotifications = application.scheduledLocalNotifications;
    
    // Cancel any notifications that might be associated with this reminder.
    for (UILocalNotification *notification in existingNotifications) {
        NSString *reminderID = notification.userInfo.reminderID;
        
        if ([reminderID isEqualToString:reminder.uuid]) {
            [application cancelLocalNotification:notification];
        }
    }
}

- (void)updateScheduleForReminder:(OHMReminder *)reminder
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    [self unscheduleNotificationsForReminder:reminder];
    [self synchronizeLocationReminders];
    
    if (!reminder.enabledValue) return;
    
    if (!reminder.isLocationReminderValue) {
        [reminder updateNextFireDate];
        [self scheduleNotificationForReminder:reminder];
    }
}

- (void)scheduleNotificationForReminder:(OHMReminder *)reminder
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSString *alertBody = [NSString stringWithFormat:@"Reminder: Take survey '%@'", reminder.survey.surveyName];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo.reminderID = reminder.uuid;
    
    NSDate *fireDate = reminder.nextFireDate;
    if (!fireDate) {
        // can't schedule a notification without a fire date
        return;
    }
    
    notification.alertBody = alertBody;
    notification.fireDate = fireDate;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)processFiredLocalNotification:(UILocalNotification *)notification
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    NSString *uuid = notification.userInfo.reminderID;
    OHMReminder *reminder = [[OHMModel sharedModel] reminderWithUUID:uuid];
    reminder.lastFireDate = notification.fireDate;
    [self processFiredReminder:reminder];
}

- (void)processFiredReminder:(OHMReminder *)reminder
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    reminder.survey.isDueValue = YES;
    
    if (reminder.weekdaysMaskValue == OHMRepeatDayNever) {
        reminder.enabledValue = NO;
    }
    
    [self updateScheduleForReminder:reminder];
    [[OHMModel sharedModel] saveModelState];
}

- (void)processArrivalAtLocationForReminder:(OHMReminder *)reminder
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    if ([reminder shouldFireLocationNotification]) {
        reminder.nextFireDate = [NSDate date];
        reminder.survey.isDueValue = YES;
        [self scheduleNotificationForReminder:reminder];
    }
}

- (void)synchronizeRemindersForLocation:(OHMReminderLocation *)location
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    BOOL shouldMonitorLocation = NO;
    for (OHMReminder *reminder in location.reminders) {
        if (reminder.isLocationReminderValue && reminder.enabledValue) {
            shouldMonitorLocation = YES;
            if (reminder.usesTimeRangeValue && reminder.alwaysShowValue) {
                [reminder updateNextFireDate];
                [self scheduleNotificationForReminder:reminder];
            }
        }
    }
    
    if (shouldMonitorLocation) {
        [[OHMLocationManager sharedLocationManager].locationManager startMonitoringForRegion:location.region];
    }
    else {
        [[OHMLocationManager sharedLocationManager].locationManager stopMonitoringForRegion:location.region];
    }
}

- (void)synchronizeLocationReminders
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    NSArray *locations = [OHMModel sharedModel].reminderLocations;
    NSMutableSet *locationIDs = [NSMutableSet setWithCapacity:locations.count];
    for (OHMReminderLocation *location in locations) {
        [self synchronizeRemindersForLocation:location];
        [locationIDs addObject:location.uuid];
    }
    
    // make sure we aren't monitoring any extra regions
    NSSet *regions = [OHMLocationManager sharedLocationManager].locationManager.monitoredRegions;
    for (CLRegion *region in regions) {
        NSString *locationID = region.identifier;
        if (![locationIDs containsObject:locationID]) {
            // if we don't have a location for this ID in our database, stop monitoring
            [[OHMLocationManager sharedLocationManager].locationManager stopMonitoringForRegion:region];
        }
    }
}

- (void)synchronizeReminders
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSArray *timeReminders = [[OHMModel sharedModel] timeReminders];
    for (OHMReminder *reminder in timeReminders) {
        if (reminder.nextFireDate != nil && [reminder.nextFireDate isBeforeDate:[NSDate date]]) {
            reminder.lastFireDate = reminder.nextFireDate;
            [self processFiredReminder:reminder];
        }
        else {
            [self scheduleNotificationForReminder:reminder];
        }
    }
    
    [self synchronizeLocationReminders];
    
    [self debugPrintAllNotifications];
}

- (void)cancelAllNotificationsForLoggedInUser
{
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    UIApplication *application = [UIApplication sharedApplication];
    OHMUser *user = [[OHMModel sharedModel] loggedInUser];
    NSArray *scheduledNotifications = [application scheduledLocalNotifications];
    for (UILocalNotification *notification in scheduledNotifications) {
        OHMReminder *reminder = [[OHMModel sharedModel] reminderWithUUID:notification.userInfo.reminderID];
        if (reminder && [reminder.user isEqual:user]) {
            [application cancelLocalNotification:notification];
        }
    }
}

- (void)debugPrintAllNotifications {
#ifdef DEBUG
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterFullStyle;
    dateFormatter.timeStyle = NSDateFormatterFullStyle;
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"There are %lu local notifications scheduled.", (unsigned long)[notifications count]);
    
    [notifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        NSString *reminderID = notification.userInfo.reminderID;
        OHMReminder *reminder = [[OHMModel sharedModel] reminderWithUUID:reminderID];
        NSDate *fireDate = notification.fireDate;
        NSLog(@"%@", [NSString stringWithFormat:@"%lu. %@, %@", idx + 1, reminder.survey.surveyName, [dateFormatter stringFromDate:fireDate]]);
    }];
    
    [[OHMLocationManager sharedLocationManager] debugPrintAllMonitoredRegions];
    
    NSArray *locations = [[OHMModel sharedModel] reminderLocations];
    for (OHMReminderLocation *location in locations) {
        NSLog(@"Location: %@ - %@", location.name, location.uuid);
        for (OHMReminder *reminder in location.reminders) {
            NSLog(@"Reminder: %@, enabled: %d", reminder.survey.surveyName, reminder.enabledValue);
        }
    }
#endif
}

@end
