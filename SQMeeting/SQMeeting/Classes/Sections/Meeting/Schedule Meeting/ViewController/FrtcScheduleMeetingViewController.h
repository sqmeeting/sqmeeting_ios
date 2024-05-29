#import "BaseViewController.h"
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleMeetingViewController : BaseViewController

@property (nonatomic, strong) FrtcScheduleDetailModel *detailInfo;

@property (nonatomic, getter=isEditing) BOOL edit;

@property (nonatomic, copy) void(^createRecurrenceMeetingSuccess)(FrtcScheduleDetailModel *model);

@property (nonatomic, copy) void(^updateRecurrenceMeetingSuccess)(NSString *reservation_id);

@end

NS_ASSUME_NONNULL_END
