#import "FrtcMeetingRecurrenceDateManager.h"
#import "NSBundle+FLanguage.h"

@implementation FrtcMeetingRecurrenceDateManager

NSString *f_daysDateResultWithInterval(NSString *interval) {
    if ([interval isEqualToString:@"1"]) {
        return FLocalized(@"recurrence_meetingRecurrenceDayly", nil);
    }else{
        NSString *recurrenceDayly = [NSString stringWithFormat:FLocalized(@"recurrence_everyDays", nil),interval];
        return [NSString stringWithFormat:@"%@%@",FLocalized(@"recurrence_meetingWillOn", nil),recurrenceDayly];
    }
}

NSString *f_weekDateResultWithInterval(NSString *interval, NSArray *resultList) {
    
    NSArray *sortedWeekdays = [resultList sortedArrayUsingComparator:^NSComparisonResult(NSString *day1, NSString *day2) {
        NSDictionary *orderDict = @{@"日": @0, @"一": @1, @"二": @2, @"三": @3, @"四": @4, @"五": @5, @"六": @6};
        NSNumber *order1 = orderDict[day1];
        NSNumber *order2 = orderDict[day2];
        return [order1 compare:order2];
    }];
    
    NSString *weekResult = @"";
    interval = [interval isEqualToString:@"1"] ? @"" : interval;
    for (int i = 0 ; i < sortedWeekdays.count; i ++) {
        NSString *item = sortedWeekdays[i];
        NSLog(@"item week = %@",item);
        if (i == sortedWeekdays.count - 1) {
            weekResult = [weekResult stringByAppendingFormat:FLocalized(@"recurrence_meetingWeekly", nil),item];
        }else{
            NSString *montageDayly = [NSString stringWithFormat:FLocalized(@"recurrence_meetingWeekly", nil),item];
            weekResult = [weekResult stringByAppendingFormat:@"%@、",montageDayly];
        }
    }
    
    NSString *weeksStr = [NSString stringWithFormat:FLocalized(@"recurrence_everyWeeks", nil),interval];
    
    if ([NSBundle isLanguageEn]) {
        return [NSString stringWithFormat:@"%@%@ %@%@",FLocalized(@"recurrence_meetingWillWeeks", nil),weekResult,weeksStr,FLocalized(@"recurrence_meetingMonthlyCycle", nil)];

    }else{
        return [NSString stringWithFormat:@"%@%@ %@%@",FLocalized(@"recurrence_meetingWillWeeks", nil),weeksStr,weekResult,FLocalized(@"recurrence_meetingMonthlyCycle", nil)];
    }
}

NSString *f_weekRecurrenceDate(NSArray *resultList) {
    NSString *weekResult = @"";
    
    for (int i = 0 ; i < resultList.count; i ++) {
        NSString *item = resultList[i];
        if (i == resultList.count - 1) {
            weekResult = [weekResult stringByAppendingFormat:FLocalized(@"recurrence_meetingWeekly", nil),item];
        }else{
            NSString *montageDayly = [NSString stringWithFormat:FLocalized(@"recurrence_meetingWeekly", nil),item];
            weekResult = [weekResult stringByAppendingFormat:@"%@、",montageDayly];
        }
    }
    return weekResult;
}

NSString *f_monthDateResultWithInterval(NSString *interval, NSArray *resultList) {
    
    NSArray *sortedStringNumbers = [resultList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *string1 = (NSString *)obj1;
        NSString *string2 = (NSString *)obj2;
        NSNumber *number1 = @([string1 integerValue]);
        NSNumber *number2 = @([string2 integerValue]);
        return [number1 compare:number2];
    }];
    
    NSString *monthResult = @"";
    interval = [interval isEqualToString:@"1"] ? @"" : interval;
    
    for (int i = 0 ; i < sortedStringNumbers.count; i ++) {
        NSString *item = sortedStringNumbers[i];
        if (i == sortedStringNumbers.count - 1) {
            monthResult = [monthResult stringByAppendingFormat:FLocalized(@"recurrence_meetingRecurrenceMonthly", nil),item];
        }else{
            NSString *montageDayly = [NSString stringWithFormat:FLocalized(@"recurrence_meetingRecurrenceMonthly", nil),item];
            monthResult = [monthResult stringByAppendingFormat:@"%@、",montageDayly];
        }
    }
    
    NSString *monthlyStr = [NSString stringWithFormat:FLocalized(@"recurrence_everyMonths", nil),interval];
    if ([NSBundle isLanguageEn]) {
        return [NSString stringWithFormat:@"%@%@ %@%@",FLocalized(@"recurrence_meetingWillWeeks", nil),monthResult,monthlyStr,FLocalized(@"recurrence_meetingMonthlyCycle", nil)];

    }else{
        return [NSString stringWithFormat:@"%@%@ %@%@",FLocalized(@"recurrence_meetingWillWeeks", nil),monthlyStr,monthResult,FLocalized(@"recurrence_meetingMonthlyCycle", nil)];
    }
}

NSString *f_monthRecurrenceDate(NSArray *resultList) {
    NSString *monthResult = @"";
    
    for (int i = 0 ; i < resultList.count; i ++) {
        NSString *item = resultList[i];
        if (i == resultList.count - 1) {
            monthResult = [monthResult stringByAppendingFormat:FLocalized(@"recurrence_meetingRecurrenceMonthly", nil),item];
        }else{
            NSString *montageDayly = [NSString stringWithFormat:FLocalized(@"recurrence_meetingRecurrenceMonthly", nil),item];
            monthResult = [monthResult stringByAppendingFormat:@"%@、",montageDayly];
        }
    }
    return monthResult;
}

NSString *f_everyNumberDaya(NSString *days) {
    if ([days isEqualToString:@"1"]) {
        return FLocalized(@"recurrence_daily", @"每天");
    }else{
        return [NSString stringWithFormat:FLocalized(@"recurrence_everyDays", nil),days];
    }
}

NSString *f_everyNumberWeeks(NSString *weeks) {
    if ([weeks isEqualToString:@"1"]) {
        return FLocalized(@"recurrence_weekly", @"每周");
    }else{
        return [NSString stringWithFormat:FLocalized(@"recurrence_everyWeeks", nil),weeks];
    }
}

NSString *f_everyNumberMonths(NSString *months) {
    if ([months isEqualToString:@"1"]) {
        return FLocalized(@"recurrence_monthly", @"每月");
    }else{
        return [NSString stringWithFormat:FLocalized(@"recurrence_everyMonths", nil),months];
    }
}

@end
