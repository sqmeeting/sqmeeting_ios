#import "FrtcScheduleDetailModel.h"
#import "FrtcUserModel.h"
#import "FrtcMeetingRecurrenceDateManager.h"

@implementation FrtcScheduleDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"invited_users_details" : [FInviteUserListInfo class]};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *mute = self.mute_upon_entry;
    if ([mute isEqualToString:@"ENABLE"]) {
        self.muteEntry = YES;
    }else{
        self.muteEntry = NO;
    }
    
    self.timeKey = [FrtcHelpers getDateCustomStringWithTimeStr:self.schedule_start_time];
    
    self.start_time = [FrtcHelpers getDateStringWithTimeStr:self.schedule_start_time];
    NSDateComponents *components = [FrtcHelpers getDateDifferenceWithBeginTimestamp:self.schedule_start_time endTimestamp:self.schedule_end_time];
    if (components.hour != 0  && components.minute != 0) {
        self.meeting_duration = [NSString stringWithFormat:@"%td %@ %td %@",components.hour,NSLocalizedString(@"hour", nil),components.minute,NSLocalizedString(@"minute", nil)];
    }else if (components.hour != 0 && components.minute == 0) {
        self.meeting_duration = [NSString stringWithFormat:@"%td %@",components.hour,NSLocalizedString(@"hour", nil)];
    }else {
        self.meeting_duration = [NSString stringWithFormat:@"%td %@",components.minute,NSLocalizedString(@"minute", nil)];
    }
    
    NSDateComponents *canComponents = [FrtcHelpers getDateDifferenceWithBeginTimestamp:[FrtcHelpers currentTimeStr] endTimestamp:self.schedule_start_time];
    NSInteger startTime = canComponents.day * 24 * 60 + canComponents.hour * 60 + canComponents.minute;
    self.timeDiff = startTime;
 
    if (f_isWithinFifteenMinutes([FrtcHelpers currentTimeStr], self.schedule_start_time)) {
        self.meeting_statusStr = NSLocalizedString(@"meeting_begin_in", nil);
    }
    
    self.meeting_timeSlot = [NSString stringWithFormat:@"%@ - %@",[FrtcHelpers getMinuteDateWithtimeStamp:self.schedule_start_time],[FrtcHelpers getMinuteDateWithtimeStamp:self.schedule_end_time]];
    
    int statrResult = [FrtcHelpers compareOneDay:[FrtcHelpers currentTimeStr] withAnotherDay:self.schedule_start_time];
    int endResult = [FrtcHelpers compareOneDay:[FrtcHelpers currentTimeStr] withAnotherDay:self.schedule_end_time];
    
    if (statrResult == 1 &&  endResult == -1) {
        self.meeting_statusStr = NSLocalizedString(@"started", nil);
        self.inMeeting = YES;
    }
    
    if (endResult == 1) {
        self.overdue = YES;
    }
    
    self.yourSelf = [self.owner_id isEqualToString:[FrtcUserModel fetchUserInfo].user_id];
    NSString *userId = [FrtcUserModel fetchUserInfo].user_id;
    self.yourSelf = [self.owner_id isEqualToString:userId];
    
    self.joinYourself = NO;
    if (!self.isYourSelf && ![self.participantUsers containsObject:userId]) {
        self.joinYourself = YES;
    }

    self.recurrence = [self.meeting_type isEqualToString:@"recurrence"];
    
    if (self.isRecurrence) {
        NSInteger meetingNumber = 0 ;
        if ([self.recurrence_type isEqualToString:@"DAILY"] ) {
            self.recurrenceType = FRecurrenceDay;
            self.recurrenceInterval_result = f_everyNumberDaya(f_stringFromInt(self.recurrenceInterval));
            meetingNumber = f_calculateMeetingCountWithStartDate(self.recurrenceStartDay, self.recurrenceEndDay, self.recurrenceInterval, NSCalendarUnitDay);
        }else if ([self.recurrence_type isEqualToString:@"WEEKLY"]) {
            self.recurrenceType = FRecurrenceWeek;
            self.recurrenceInterval_result = f_everyNumberWeeks(f_stringFromInt(self.recurrenceInterval));
            meetingNumber = f_calculateMeetingCountWithStartDate(self.recurrenceStartDay, self.recurrenceEndDay, self.recurrenceInterval, NSCalendarUnitWeekOfYear);
            if (self.recurrenceDaysOfWeek.count > 1) {
                meetingNumber = meetingNumber * self.recurrenceDaysOfWeek.count;
            }
        }else if ([self.recurrence_type isEqualToString:@"MONTHLY"]){
            self.recurrenceType = FRecurrenceMonth;
            self.recurrenceInterval_result = f_everyNumberMonths(f_stringFromInt(self.recurrenceInterval));
            meetingNumber = f_calculateMeetingCountWithStartDate(self.recurrenceStartDay, self.recurrenceEndDay, self.recurrenceInterval, NSCalendarUnitMonth);
            if (self.recurrenceDaysOfMonth.count > 1) {
                meetingNumber = meetingNumber * self.recurrenceDaysOfMonth.count;
            }
        }else{
            self.recurrenceType = FRecurrenceNone;
        }
        
        NSString *stopDateStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingStopTime", nil),[FrtcHelpers getDateCustomStringWithTimeStr:self.recurrenceEndDay]];
        self.recurrenceStopTime_str = stopDateStr;
        
        NSString *meetingNumberStr = [NSString stringWithFormat:FLocalized(@"recurrence_meetingTotalNumber", nil),meetingNumber];
        self.stopTimeAndMeetingNumber = [NSString stringWithFormat:@"%@ %@",stopDateStr,meetingNumberStr];
        
    }
    
    return YES;
}

@end


@implementation FScheduleListDataModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"meeting_schedules" : [FrtcScheduleDetailModel class]};
}
@end


