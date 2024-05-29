#import "FrtcCycleSettingViewController.h"
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcChangeOneRecurrenceViewController : FrtcCycleSettingViewController

@property (nonatomic, copy) void(^UpdateDetailMeetingView)(NSString *reId);

@property (nonatomic, strong) FrtcScheduleDetailModel *detailInfo;

@property (nonatomic, strong) NSArray <FrtcScheduleDetailModel *> *groupMeetingList;

@end

NS_ASSUME_NONNULL_END
