#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RecurrenceDatePickerViewBlock) (NSString *timeStamp);

@interface FrtcRecurrenceDatePickerView : UIView

+ (void)showRecurrenceDatePickerViewWithDefaultDate:(NSDate *)dafaultDate
                                            maxDate:(NSDate *)maxDate
                                              block:(RecurrenceDatePickerViewBlock)datePickerBlock;

@end

NS_ASSUME_NONNULL_END
