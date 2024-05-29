#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleRateListViewController : BaseViewController

@property (nonatomic, copy) void(^rateResultCallBack)(NSString *rate);
@property (nonatomic, copy) NSString *rate;

@end

NS_ASSUME_NONNULL_END
