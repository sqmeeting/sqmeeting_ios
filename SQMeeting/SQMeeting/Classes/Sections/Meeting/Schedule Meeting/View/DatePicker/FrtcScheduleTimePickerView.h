#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TimePickerViewBlock) (NSString *hh, NSString *mm);

@interface FrtcScheduleTimePickerView : UIView

+ (void)showTimePickerViewWithTimeStr:(TimePickerViewBlock)datePickerBlock;

@end

NS_ASSUME_NONNULL_END
