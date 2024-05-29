#import "FrtcHelpers.h"
#import "Reachability.h"
#include <sys/utsname.h>
#import "FrtcManager.h"
#import "MBProgressHUD+Extensions.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#import <UIKit/UIWindowScene.h>
#import <UIKit/UIStatusBarManager.h>
#endif

@implementation FrtcHelpers

NSDate *f_calculateEndDate(NSDate* startDate, NSCalendarUnit periodType, NSInteger periodLength, NSInteger numPeriods) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    if (periodType == NSCalendarUnitDay) {
        [components setDay:periodLength * numPeriods];
    } else if (periodType == NSCalendarUnitWeekOfYear) {
        [components setDay:(periodLength * 7) * numPeriods];
    } else if (periodType == NSCalendarUnitMonth) {
        [components setMonth:periodLength * numPeriods];
    } else {
        return nil;
    }
    
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    if (periodType == NSCalendarUnitWeekOfYear) {
        NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:endDate];
        int daysToSunday = 8 - (int)[weekdayComponents weekday];
        [components setDay:daysToSunday];
        endDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    } else if (periodType == NSCalendarUnitMonth) {
        NSRange daysRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:endDate];
        [components setDay:daysRange.length];
        endDate = [calendar dateBySettingUnit:NSCalendarUnitDay value:daysRange.length ofDate:endDate options:0];
        NSDateComponents *endOfDayComponents = [[NSDateComponents alloc] init];
        [endOfDayComponents setHour:23];
        [endOfDayComponents setMinute:59];
        [endOfDayComponents setSecond:59];
        endDate = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:endDate options:0];
    }
    
    NSDate *maxEndDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:365 toDate:startDate options:0];
    if ([endDate compare:maxEndDate] == NSOrderedDescending) {
        endDate = maxEndDate;
    }
    
    return endDate;
}

NSString *f_getDateForNSDate(NSDate *date) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

NSString *f_getCurrentWeekday() {
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:currentDate];
    NSInteger weekday = [components weekday];
    NSArray *weekdays = @[@"", FLocalized(@"recurrence_sun", nil), FLocalized(@"recurrence_mon", nil), FLocalized(@"recurrence_tue", nil), FLocalized(@"recurrence_wed", nil), FLocalized(@"recurrence_thu", nil), FLocalized(@"recurrence_fri", nil), FLocalized(@"recurrence_sat", nil)];
    NSString *weekdayString = weekdays[weekday];
    return weekdayString;
}

NSString *f_getCurrentDay() {
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSInteger day = [components day];
    return [NSString stringWithFormat:@"%ld", (long)day];
}

NSString *f_dayOfWeekForMilliseconds(NSString *milliseconds) {
    NSTimeInterval seconds = [milliseconds longLongValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayIndex = [calendar component:NSCalendarUnitWeekday fromDate:date];
    NSArray *weekdayNames = @[@"", FLocalized(@"recurrence_sun", nil), FLocalized(@"recurrence_mon", nil), FLocalized(@"recurrence_tue", nil), FLocalized(@"recurrence_wed", nil), FLocalized(@"recurrence_thu", nil), FLocalized(@"recurrence_fri", nil), FLocalized(@"recurrence_sat", nil)];
    NSString *dayOfWeek = weekdayNames[dayIndex];
    return dayOfWeek;
}

NSString *f_dayOfDayForMilliseconds(NSString *milliseconds) {
    NSTimeInterval seconds = [milliseconds longLongValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSInteger day = [components day];
    return [NSString stringWithFormat:@"%ld", (long)day];
}

NSString *f_formattedDateStringFromTimestamp(NSString *milliseconds) {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[milliseconds longLongValue] / 1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

NSArray *f_convertToNumber(NSArray *chineseWeekday) {
    NSMutableArray *resultWeeks = [[NSMutableArray alloc]initWithCapacity:7];
    for (NSString *item in chineseWeekday) {
        if ([item isEqualToString:FLocalized(@"recurrence_sun", nil)]) {
            [resultWeeks addObject:@"1"];
        }
        if ([item isEqualToString:FLocalized(@"recurrence_mon", nil)]) {
            [resultWeeks addObject:@"2"];
        }
        if ([item isEqualToString:FLocalized(@"recurrence_tue", nil)]) {
            [resultWeeks addObject:@"3"];
        }
        if ([item isEqualToString:FLocalized(@"recurrence_wed", nil)]) {
            [resultWeeks addObject:@"4"];
        }
        if ([item isEqualToString:FLocalized(@"recurrence_thu", nil)]) {
            [resultWeeks addObject:@"5"];
        }
        if ([item isEqualToString:FLocalized(@"recurrence_fri", nil)]) {
            [resultWeeks addObject:@"6"];
        }
        if ([item isEqualToString:FLocalized(@"recurrence_sat", nil)]) {
            [resultWeeks addObject:@"7"];
        }
    }
    return resultWeeks;
}

NSArray *f_convertToChineseWeekday(NSArray *numberday) {
    NSMutableArray *resultWeeks = [[NSMutableArray alloc]initWithCapacity:7];
    for (id item in numberday) {
        if ([item intValue] == 1) {
            [resultWeeks addObject:FLocalized(@"recurrence_sun", nil)];
        }
        if ([item intValue] == 2) {
            [resultWeeks addObject:FLocalized(@"recurrence_mon", nil)];
        }
        if ([item intValue] == 3) {
            [resultWeeks addObject:FLocalized(@"recurrence_tue", nil)];
        }
        if ([item intValue] == 4) {
            [resultWeeks addObject:FLocalized(@"recurrence_wed", nil)];
        }
        if ([item intValue] == 5) {
            [resultWeeks addObject:FLocalized(@"recurrence_thu", nil)];
        }
        if ([item intValue] == 6) {
            [resultWeeks addObject:FLocalized(@"recurrence_fri", nil)];
        }
        if ([item intValue] == 7) {
            [resultWeeks addObject:FLocalized(@"recurrence_sat", nil)];
        }
    }
    return resultWeeks;
}

NSDate *f_dateFromMilliseconds(NSString *milliseconds) {
    NSTimeInterval seconds = [milliseconds longLongValue] / 1000;
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

NSString *f_millisecondsFromDate(NSDate *date) {
    NSTimeInterval milliseconds = [date timeIntervalSince1970] * 1000.0;
    return [NSString stringWithFormat:@"%.f",milliseconds];
}

NSInteger f_calculateMeetingCountWithStartDate(NSString *startM, NSString *endM, NSInteger interval, NSCalendarUnit calendarUnit) {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = f_dateFromMilliseconds(startM);
    NSDate *endDate = f_dateFromMilliseconds(endM);
    
    NSDateComponents *components;
    components = [calendar components:calendarUnit
                             fromDate:startDate
                               toDate:endDate
                              options:0];
    
    NSInteger totalUnits = [components valueForComponent:calendarUnit] + interval;
    NSInteger meetingCount = totalUnits / interval;
    return meetingCount;
}

NSString *f_nextTimeNodeTimestampMilliseconds(NSString * _Nonnull timesTamp) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    if (!kStringIsEmpty(timesTamp)) {
        currentDate = [NSDate dateWithTimeIntervalSince1970:[timesTamp longLongValue]];
    }
    
    NSDateComponents *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:currentDate];
    NSInteger currentHour = [components hour];
    NSInteger currentMinute = [components minute];
    
    NSInteger timeNodes[] = {0, 15, 30, 45};
    
    for (NSInteger i = 0; i < sizeof(timeNodes) / sizeof(timeNodes[0]); i++) {
        if (currentMinute < timeNodes[i]) {
            NSDate *nextTimeNode = [calendar dateBySettingHour:currentHour minute:timeNodes[i] second:0 ofDate:currentDate options:0];
            return [NSString stringWithFormat:@"%.f",[nextTimeNode timeIntervalSince1970] * 1000];
        }
    }
    
    if (currentHour < 23) {
        NSInteger nextHour = currentHour + 1;
        NSDate *nextTimeNode = [calendar dateBySettingHour:nextHour minute:timeNodes[0] second:0 ofDate:currentDate options:0];
        return [NSString stringWithFormat:@"%.f",[nextTimeNode timeIntervalSince1970] * 1000];
    }
    else{
        if (currentMinute >= timeNodes[sizeof(timeNodes) / sizeof(timeNodes[0]) - 1]) {
            NSDate *nextTimeNode = [calendar dateBySettingHour:timeNodes[0] minute:0 second:0 ofDate:[currentDate dateByAddingTimeInterval:24 * 60 * 60] options:0];
            return [NSString stringWithFormat:@"%.f",[nextTimeNode timeIntervalSince1970] * 1000];
        }
    }
    return @"";
}

NSString *FLocalized(NSString *key, NSString * _Nullable comment) {
    return NSLocalizedString(key, comment);
}

NSString *f_stringFromInt(NSInteger intValue) {
    return [NSString stringWithFormat:@"%ld", (long)intValue];
}

NSString *f_calculateOneYearLaterEvent(NSString *milliseconds) {
    if (milliseconds == nil) { return nil; }
    NSDate *startDate = f_dateFromMilliseconds(milliseconds);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *oneYearLater = [[NSDateComponents alloc] init];
    oneYearLater.year = 1;
    NSDate *endDate = [calendar dateByAddingComponents:oneYearLater toDate:startDate options:0];
    endDate = [endDate dateByAddingTimeInterval:-86400];
    return f_millisecondsFromDate(endDate);
}

NSString *f_getSundayAfterWeeks(NSInteger weeks, NSString *startMilliseconds) {
    NSDate *startDate = f_dateFromMilliseconds(startMilliseconds);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:startDate];
    NSInteger daysToSunday = (8 - [comps weekday]) % 7;
    NSDate *nextSunday = [calendar dateByAddingUnit:NSCalendarUnitDay value:daysToSunday toDate:startDate options:0];
    NSDate *sundayAfterWeeks = [calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:weeks toDate:nextSunday options:0];
    return f_millisecondsFromDate(sundayAfterWeeks);
}

NSString *f_getLastDayAfterMonths(NSInteger months, NSString *startMilliseconds) {
    NSDate *startDate = f_dateFromMilliseconds(startMilliseconds);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:startDate];
    [comps setDay:1];
    [comps setMonth:[comps month] + months];
    NSDate *firstDayAfterMonths = [calendar dateFromComponents:comps];
    
    NSDateComponents *addComps = [[NSDateComponents alloc] init];
    [addComps setMonth:1];
    [addComps setDay:-1];
    NSDate *lastDayAfterMonths = [calendar dateByAddingComponents:addComps toDate:firstDayAfterMonths options:0];
    return f_millisecondsFromDate(lastDayAfterMonths);
}

BOOL f_isWithinFifteenMinutes(NSString *startMill,NSString *endMill) {
    NSDate *startDate = f_dateFromMilliseconds(startMill);
    NSDate *endDate = f_dateFromMilliseconds(endMill);
    
    if (!startDate || !endDate) {
        return NO;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:startDate toDate:endDate options:0];
    return (components.minute >= 0 && components.minute <= 15);
}

//BOOL f_isInMieetng() {
//    if (FrtcManager.isInMeeting) {
//        [MBProgressHUD showActivityMessage:@"您正在会议中"];
//        return YES;
//    }else{
//        return NO;
//    }
//}

+ (BOOL)f_isInMieeting {
    if (FrtcManager.isInMeeting) {
        ISMLog(@"您正在会议中");
        //[MBProgressHUD showActivityMessage:@"您正在会议中"];
        return YES;
    }
    return NO;
}

+ (UIViewController *)getCurrentVC {
    UIViewController *rootViewController;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
#pragma clang diagnostic pop
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}

+ (BOOL)isNum:(NSString *)checkedNumString {
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}

+ (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (NSString *)getDateStringWithTimeStr:(NSString *)str{
    NSTimeInterval time=[str doubleValue]/1000;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([self isTodayWithTimeStr:detailDate]) {
        [dateFormatter setDateFormat:@"a HH:mm"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

+ (NSString *)getDateStringWithTime:(NSString *)str{
    NSTimeInterval time=[str doubleValue]/1000;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

+ (NSString *)getDateCustomStringWithTimeStr:(NSString *)str {
    NSTimeInterval time=[str doubleValue]/1000;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

+ (NSString *)getDateWithtimeStamp:(NSString *)str{
    NSTimeInterval time=[str doubleValue]/1000;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([self isTodayWithTimeStr:detailDate]) {
        [dateFormatter setDateFormat:@"MM-dd"];
    }else{
        [dateFormatter setDateFormat:@"MM-dd"];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

+ (NSString *)getMinuteDateWithtimeStamp:(NSString *)str {
    NSTimeInterval time=[str doubleValue]/1000;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

+ (NSString *)getMMDDHHMMDateWithtimeStamp:(NSString *)str {
    NSTimeInterval time=[str doubleValue]/1000;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

+ (BOOL)isTodayWithTimeStr:(NSDate *)time {
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:time];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        return YES;
    }
    return NO;
}

+ (NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}

+ (NSString *)timeStampConversionNSString:(NSString *)timeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStamp longLongValue]/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if ([self isTodayWithTimeStr:date]) {
        [formatter setDateFormat:@"a HH:mm"];
    }else{
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
    }
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSString *)getResultDateWith:(NSString *)startDate timeInterval:(NSInteger)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[startDate longLongValue] / 1000];
    NSDate *resultDate = [NSDate dateWithTimeInterval:60 * (timeInterval) sinceDate:date];
    return [NSString stringWithFormat:@"%ld", (long)[resultDate timeIntervalSince1970] * 1000];
}

+ (BOOL)isSameDay:(long)iTime1 Time2:(long)iTime2
{
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:iTime1/1000];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:iTime2/1000];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (NSDateComponents *)getDateDifferenceWithBeginTimestamp:(NSString*)beginTimestamp
                                             endTimestamp:(NSString*)endTimestamp {
    
    NSTimeInterval timer1 = [beginTimestamp doubleValue];
    NSTimeInterval timer2 = [endTimestamp doubleValue];
    
    if (timer1 == 0 || timer2 ==0) {
        return 0;
    }
    
    if (beginTimestamp.length >= 13) {
        timer1 = timer1 / 1000;
    }
    if (endTimestamp.length >= 13) {
        timer2 = timer2 / 1000;
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timer1];
    
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timer2];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:date2 options:0];
    
    return cmps;
}

+ (int)compareOneDay:(NSString *)timeStamp1 withAnotherDay:(NSString *)timeStamp2
{
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:[timeStamp1 longLongValue]/1000];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:[timeStamp2 longLongValue]/1000];
    NSComparisonResult result = [pDate1 compare:pDate2];
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
}

+ (BOOL)isNetwork {
    Reachability *reachability   = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    BOOL net = YES;
    switch (internetStatus) {
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            net = YES;
            break;
        case NotReachable:
            net = NO;
        default:
            break;
    }
    return net;
}

+ (UIWindow *)keyWindow
{
    static __weak UIWindow *cachedKeyWindow = nil;
    
    UIWindow *originalKeyWindow = nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        originalKeyWindow = window;
                        break;
                    }
                }
            }
        }
    } else
#endif
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
        originalKeyWindow = [UIApplication sharedApplication].keyWindow;
#endif
    }
    
    if (originalKeyWindow)
    {
        cachedKeyWindow = originalKeyWindow;
    }
    
    return cachedKeyWindow;
}

+ (NSDictionary *) getDeviceNamesByCode {
    return @{
        @"iPod1,1": @"iPod Touch", // (Original)
        @"iPod2,1": @"iPod Touch", // (Second Generation)
        @"iPod3,1": @"iPod Touch", // (Third Generation)
        @"iPod4,1": @"iPod Touch", // (Fourth Generation)
        @"iPod5,1": @"iPod Touch", // (Fifth Generation)
        @"iPod7,1": @"iPod Touch", // (Sixth Generation)
        @"iPod9,1": @"iPod Touch", // (Seventh Generation)
        @"iPhone1,1": @"iPhone", // (Original)
        @"iPhone1,2": @"iPhone 3G", // (3G)
        @"iPhone2,1": @"iPhone 3GS", // (3GS)
        @"iPad1,1": @"iPad", // (Original)
        @"iPad2,1": @"iPad 2", //
        @"iPad2,2": @"iPad 2", //
        @"iPad2,3": @"iPad 2", //
        @"iPad2,4": @"iPad 2", //
        @"iPad3,1": @"iPad", // (3rd Generation)
        @"iPad3,2": @"iPad", // (3rd Generation)
        @"iPad3,3": @"iPad", // (3rd Generation)
        @"iPhone3,1": @"iPhone 4", // (GSM)
        @"iPhone3,2": @"iPhone 4", // iPhone 4
        @"iPhone3,3": @"iPhone 4", // (CDMA/Verizon/Sprint)
        @"iPhone4,1": @"iPhone 4S", //
        @"iPhone5,1": @"iPhone 5", // (model A1428, AT&T/Canada)
        @"iPhone5,2": @"iPhone 5", // (model A1429, everything else)
        @"iPad3,4": @"iPad", // (4th Generation)
        @"iPad3,5": @"iPad", // (4th Generation)
        @"iPad3,6": @"iPad", // (4th Generation)
        @"iPad2,5": @"iPad Mini", // (Original)
        @"iPad2,6": @"iPad Mini", // (Original)
        @"iPad2,7": @"iPad Mini", // (Original)
        @"iPhone5,3": @"iPhone 5c", // (model A1456, A1532 | GSM)
        @"iPhone5,4": @"iPhone 5c", // (model A1507, A1516, A1526 (China), A1529 | Global)
        @"iPhone6,1": @"iPhone 5s", // (model A1433, A1533 | GSM)
        @"iPhone6,2": @"iPhone 5s", // (model A1457, A1518, A1528 (China), A1530 | Global)
        @"iPhone7,1": @"iPhone 6 Plus", //
        @"iPhone7,2": @"iPhone 6", //
        @"iPhone8,1": @"iPhone 6s", //
        @"iPhone8,2": @"iPhone 6s Plus", //
        @"iPhone8,4": @"iPhone SE", //
        @"iPhone9,1": @"iPhone 7", // (model A1660 | CDMA)
        @"iPhone9,3": @"iPhone 7", // (model A1778 | Global)
        @"iPhone9,2": @"iPhone 7 Plus", // (model A1661 | CDMA)
        @"iPhone9,4": @"iPhone 7 Plus", // (model A1784 | Global)
        @"iPhone10,3": @"iPhone X", // (model A1865, A1902)
        @"iPhone10,6": @"iPhone X", // (model A1901)
        @"iPhone10,1": @"iPhone 8", // (model A1863, A1906, A1907)
        @"iPhone10,4": @"iPhone 8", // (model A1905)
        @"iPhone10,2": @"iPhone 8 Plus", // (model A1864, A1898, A1899)
        @"iPhone10,5": @"iPhone 8 Plus", // (model A1897)
        @"iPhone11,2": @"iPhone XS", // (model A2097, A2098)
        @"iPhone11,4": @"iPhone XS Max", // (model A1921, A2103)
        @"iPhone11,6": @"iPhone XS Max", // (model A2104)
        @"iPhone11,8": @"iPhone XR", // (model A1882, A1719, A2105)
        @"iPhone12,1": @"iPhone 11",
        @"iPhone12,3": @"iPhone 11 Pro",
        @"iPhone12,5": @"iPhone 11 Pro Max",
        @"iPhone12,8": @"iPhone SE", // (2nd Generation iPhone SE),
        @"iPhone13,1": @"iPhone 12 mini",
        @"iPhone13,2": @"iPhone 12",
        @"iPhone13,3": @"iPhone 12 Pro",
        @"iPhone13,4": @"iPhone 12 Pro Max",
        @"iPhone14,4": @"iPhone 13 mini",
        @"iPhone14,5": @"iPhone 13",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPhone14,6": @"iPhone SE (3rd generation)",
        @"iPhone14,7": @"iPhone 14",
        @"iPhone14,8": @"iPhone 14 Plus",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,3": @"iPhone 14 Pro Max",
        
        @"iPad4,1": @"iPad Air", // 5th Generation iPad (iPad Air) - Wifi
        @"iPad4,2": @"iPad Air", // 5th Generation iPad (iPad Air) - Cellular
        @"iPad4,3": @"iPad Air", // 5th Generation iPad (iPad Air)
        @"iPad4,4": @"iPad Mini 2", // (2nd Generation iPad Mini - Wifi)
        @"iPad4,5": @"iPad Mini 2", // (2nd Generation iPad Mini - Cellular)
        @"iPad4,6": @"iPad Mini 2", // (2nd Generation iPad Mini)
        @"iPad4,7": @"iPad Mini 3", // (3rd Generation iPad Mini)
        @"iPad4,8": @"iPad Mini 3", // (3rd Generation iPad Mini)
        @"iPad4,9": @"iPad Mini 3", // (3rd Generation iPad Mini)
        @"iPad5,1": @"iPad Mini 4", // (4th Generation iPad Mini)
        @"iPad5,2": @"iPad Mini 4", // (4th Generation iPad Mini)
        @"iPad5,3": @"iPad Air 2", // 6th Generation iPad (iPad Air 2)
        @"iPad5,4": @"iPad Air 2", // 6th Generation iPad (iPad Air 2)
        @"iPad6,3": @"iPad Pro 9.7-inch", // iPad Pro 9.7-inch
        @"iPad6,4": @"iPad Pro 9.7-inch", // iPad Pro 9.7-inch
        @"iPad6,7": @"iPad Pro 12.9-inch", // iPad Pro 12.9-inch
        @"iPad6,8": @"iPad Pro 12.9-inch", // iPad Pro 12.9-inch
        @"iPad6,11": @"iPad (5th generation)", // Apple iPad 9.7 inch (5th generation) - WiFi
        @"iPad6,12": @"iPad (5th generation)", // Apple iPad 9.7 inch (5th generation) - WiFi + cellular
        @"iPad7,1": @"iPad Pro 12.9-inch", // 2nd Generation iPad Pro 12.5-inch - Wifi
        @"iPad7,2": @"iPad Pro 12.9-inch", // 2nd Generation iPad Pro 12.5-inch - Cellular
        @"iPad7,3": @"iPad Pro 10.5-inch", // iPad Pro 10.5-inch - Wifi
        @"iPad7,4": @"iPad Pro 10.5-inch", // iPad Pro 10.5-inch - Cellular
        @"iPad7,5": @"iPad (6th generation)", // iPad (6th generation) - Wifi
        @"iPad7,6": @"iPad (6th generation)", // iPad (6th generation) - Cellular
        @"iPad7,11": @"iPad (7th generation)", // iPad 10.2 inch (7th generation) - Wifi
        @"iPad7,12": @"iPad (7th generation)", // iPad 10.2 inch (7th generation) - Wifi + cellular
        @"iPad8,1": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - Wifi
        @"iPad8,2": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - 1TB - Wifi
        @"iPad8,3": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - Wifi + cellular
        @"iPad8,4": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - 1TB - Wifi + cellular
        @"iPad8,5": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - Wifi
        @"iPad8,6": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - 1TB - Wifi
        @"iPad8,7": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - Wifi + cellular
        @"iPad8,8": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - 1TB - Wifi + cellular
        @"iPad8,9": @"iPad Pro (11-inch) (2nd generation)",
        @"iPad8,10": @"iPad Pro (11-inch) (2nd generation)",
        @"iPad8,11": @"iPad Pro (12.9-inch) (4th generation)",
        @"iPad8,12": @"iPad Pro (12.9-inch) (4th generation)",
        @"iPad13,4": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,5": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,6": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,7": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,8": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,9": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,10": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,11": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad11,1": @"iPad Mini 5", // (5th Generation iPad Mini)
        @"iPad11,2": @"iPad Mini 5", // (5th Generation iPad Mini)
        @"iPad14,1": @"iPad Mini 6",
        @"iPad14,2": @"iPad Mini 6",
        @"iPad11,3": @"iPad Air (3rd generation)",
        @"iPad11,4": @"iPad Air (3rd generation)",
        @"iPad13,1": @"iPad Air (4th generation)",
        @"iPad13,2": @"iPad Air (4th generation)",
        @"iPad13,16": @"iPad Air (5th generation)",
        @"iPad13,17": @"iPad Air (5th generation)",
        
        @"AppleTV2,1": @"Apple TV", // Apple TV (2nd Generation)
        @"AppleTV3,1": @"Apple TV", // Apple TV (3rd Generation)
        @"AppleTV3,2": @"Apple TV", // Apple TV (3rd Generation - Rev A)
        @"AppleTV5,3": @"Apple TV", // Apple TV (4th Generation)
        @"AppleTV6,2": @"Apple TV 4K" // Apple TV 4K
        
    };
}

+ (NSString *) getModel {
    NSString* deviceId = [self getDeviceId];
    NSDictionary* deviceNamesByCode = [self getDeviceNamesByCode];
    NSString* deviceName =[deviceNamesByCode valueForKey:deviceId];
    
    // Return the real device name if we have it
    if (deviceName) {
        return deviceName;
    }
    
    // If we don't have the real device name, try a generic
    if ([deviceId hasPrefix:@"iPod"]) {
        return @"iPod Touch";
    } else if ([deviceId hasPrefix:@"iPad"]) {
        return @"iPad";
    } else if ([deviceId hasPrefix:@"iPhone"]) {
        return @"iPhone";
    } else if ([deviceId hasPrefix:@"AppleTV"]) {
        return @"Apple TV";
    }
    
    // If we could not even get a generic, it's unknown
    return @"unknown";
}

+ (NSString *) getDeviceId {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceId = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
#if TARGET_IPHONE_SIMULATOR
    deviceId = [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
#endif
    return deviceId;
}

@end

