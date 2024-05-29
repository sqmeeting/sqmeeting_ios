#import <UIKit/UIKit.h>
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcHomeRecurrenceGroupHeaderView : UIView

@property (nonatomic, strong) FrtcScheduleDetailModel *detailModel;

@property (nonatomic, strong) UILabel *meetingStopTimeLabel;

@end

NS_ASSUME_NONNULL_END
