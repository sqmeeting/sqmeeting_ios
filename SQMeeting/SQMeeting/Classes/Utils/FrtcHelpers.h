#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface FrtcHelpers : NSObject

NSDate *f_calculateEndDate(NSDate* startDate, NSCalendarUnit periodType, NSInteger periodLength, NSInteger numPeriods);

NSString *f_getDateForNSDate(NSDate *date);

NSString *f_getCurrentWeekday();

NSString *f_getCurrentDay();

NSString *f_dayOfWeekForMilliseconds(NSString *milliseconds);

NSString *f_dayOfDayForMilliseconds(NSString *milliseconds);

NSString *f_formattedDateStringFromTimestamp(NSString *milliseconds);

NSArray *f_convertToNumber(NSArray *chineseWeekday);

NSArray *f_convertToChineseWeekday(NSArray *numberday);

NSDate *f_dateFromMilliseconds(NSString *milliseconds);

NSString *f_millisecondsFromDate(NSDate *date);

NSInteger f_calculateMeetingCountWithStartDate(NSString *startM, NSString *endM, NSInteger interval, NSCalendarUnit calendarUnit);

NSString *FLocalized(NSString *key, NSString * _Nullable comment);

NSString *f_nextTimeNodeTimestampMilliseconds(NSString * _Nonnull timesTamp);

NSString *f_stringFromInt(NSInteger intValue);

NSString *f_calculateOneYearLaterEvent(NSString *milliseconds);

NSString *f_getSundayAfterWeeks(NSInteger weeks, NSString *startMilliseconds);

NSString *f_getLastDayAfterMonths(NSInteger months, NSString *startMilliseconds);

BOOL f_isWithinFifteenMinutes(NSString *startMill,NSString *endMill);

//BOOL f_isInMieetng();
+ (BOOL)f_isInMieeting;

+ (UIViewController *)getCurrentVC;

+ (BOOL)isNum:(NSString *)checkedNumString;

+ (NSString *)currentTimeStr;

+ (NSString *)getDateStringWithTimeStr:(NSString *)str;

+ (NSString *)getDateStringWithTime:(NSString *)str;

+ (NSString *)getDateCustomStringWithTimeStr:(NSString *)str;

+ (NSString *)getDateWithtimeStamp:(NSString *)str;

+ (NSString *)getMinuteDateWithtimeStamp:(NSString *)str;

+ (NSString *)getMMDDHHMMDateWithtimeStamp:(NSString *)str;

+ (NSString *)timeStampConversionNSString:(NSString *)timeStamp;

+ (NSString *)getResultDateWith:(NSString *)startDate timeInterval:(NSInteger)timeInterval;

+ (BOOL)isSameDay:(long)iTime1 Time2:(long)iTime2;

+ (NSDateComponents *)getDateDifferenceWithBeginTimestamp:(NSString*)beginTimestamp
                                             endTimestamp:(NSString*)endTimestamp;

+ (int)compareOneDay:(NSString *)timeStamp1 withAnotherDay:(NSString *)timeStamp2;

+ (BOOL)isNetwork;

+ (UIWindow *)keyWindow;

+ (NSString *)getModel;

@end

NS_ASSUME_NONNULL_END

