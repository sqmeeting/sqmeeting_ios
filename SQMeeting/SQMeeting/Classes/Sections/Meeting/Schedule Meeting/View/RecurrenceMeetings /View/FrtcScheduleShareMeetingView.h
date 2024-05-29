#import <UIKit/UIKit.h>
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScheduleShareMeetingViewBlock) (void);

@interface FrtcScheduleShareMeetingView : UIView

+ (void)showScheduleShareMeetingViewModel:(FrtcScheduleDetailModel *)model block:(ScheduleShareMeetingViewBlock)datePickerBlock;

@end

NS_ASSUME_NONNULL_END
