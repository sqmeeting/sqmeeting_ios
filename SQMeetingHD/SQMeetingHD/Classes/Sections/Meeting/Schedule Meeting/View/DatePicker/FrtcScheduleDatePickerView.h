#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DatePickerViewBlock) (NSString *timeStamp);

@interface FrtcScheduleDatePickerView : UIView

+ (void)showDatePickerViewWithMinimumDate:(NSString *)minDate
                                  maxDate:(NSString *)maxDate
                              DefaultDate:(NSString *)dafaultDate
                                dateBlock:(DatePickerViewBlock)datePickerBlock;

@end

NS_ASSUME_NONNULL_END
