#import "BaseViewController.h"
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcChangeOneRecurrenceViewController : BaseViewController

@property (nonatomic, copy) void(^UpdateDetailMeetingView)(NSString *reId);

@property (nonatomic, strong) NSArray <FrtcScheduleDetailModel *> *groupMeetingList;

@property (nonatomic, strong) FrtcScheduleDetailModel *detailInfo;

@end

NS_ASSUME_NONNULL_END
