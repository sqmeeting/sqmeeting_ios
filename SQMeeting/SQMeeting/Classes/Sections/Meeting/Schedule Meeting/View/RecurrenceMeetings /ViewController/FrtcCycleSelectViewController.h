#import "BaseViewController.h"
#import "FrtcScheduleMeetingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcCycleSelectViewController : BaseViewController

@property (nonatomic, copy) void(^recurrentSelectMeetingResult)(FRecurrentMeetingResutModel *model);
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) FRecurrentMeetingResutModel *editModel;
@property (nonatomic, getter=isEditing) BOOL edit;

@end

NS_ASSUME_NONNULL_END
