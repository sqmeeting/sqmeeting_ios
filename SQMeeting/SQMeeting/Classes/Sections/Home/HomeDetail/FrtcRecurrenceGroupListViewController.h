#import "BaseViewController.h"
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcRecurrenceGroupListViewController : BaseViewController

@property (nonatomic, copy) void(^updateGroupListMeetingList)(void);
@property (nonatomic, copy) void(^updateRecurrenceMeetingModel)(NSString *rid);
@property (nonatomic, strong) NSString *group_id;
@property (nonatomic, strong) FrtcScheduleDetailModel *detailInfo;

@property (nonatomic, assign) BOOL isYourSelfJoin;

@end

NS_ASSUME_NONNULL_END
