#import "FrtcHDBaseViewController.h"
#import "FrtcRecurSelectView.h"
#import "FrtcScheduleMeetingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcCycleSettingViewController : FrtcHDBaseViewController

@property (nonatomic, copy) void(^recurrentMeetingResult)(FRecurrentMeetingResutModel *model);
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, assign) FRecurrenceType settingType;
@property (nonatomic, strong) FRecurrentMeetingResutModel *editSettingModel;

@end

NS_ASSUME_NONNULL_END
