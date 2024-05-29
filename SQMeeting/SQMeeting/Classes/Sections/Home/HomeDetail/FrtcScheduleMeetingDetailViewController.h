#import "BaseViewController.h"
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleMeetingDetailViewController : BaseViewController

@property (nonatomic, copy) void(^updateScheduledMeetingList)(void);

@property (nonatomic, strong) FrtcScheduleDetailModel *detailInfo;

@property (nonatomic, assign) BOOL isPush;

@property (nonatomic, strong) NSString *meetingId;

@property (nonatomic, assign) BOOL isRecurrenceList;

@property (nonatomic, assign) BOOL isYourSelfJoin;

@end

NS_ASSUME_NONNULL_END
