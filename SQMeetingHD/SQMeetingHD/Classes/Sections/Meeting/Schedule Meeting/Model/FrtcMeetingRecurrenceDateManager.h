#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingRecurrenceDateManager : NSObject

NSString *f_daysDateResultWithInterval(NSString *interval);

NSString *f_weekDateResultWithInterval(NSString *interval, NSArray *resultList);
NSString *f_weekRecurrenceDate(NSArray *resultList);

NSString *f_monthDateResultWithInterval(NSString *interval, NSArray *resultList);
NSString *f_monthRecurrenceDate(NSArray *resultList);

NSString *f_everyNumberDaya(NSString *days);

NSString *f_everyNumberWeeks(NSString *weeks);

NSString *f_everyNumberMonths(NSString *months);

@end

NS_ASSUME_NONNULL_END
