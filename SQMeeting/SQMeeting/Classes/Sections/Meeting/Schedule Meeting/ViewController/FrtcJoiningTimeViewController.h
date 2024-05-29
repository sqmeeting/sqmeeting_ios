#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcJoiningTimeViewController : BaseViewController

@property (nonatomic, copy) void(^joiningTimeResultCallBack)(NSString *time);

@property (nonatomic, copy) NSString *joiningTime;

@end

NS_ASSUME_NONNULL_END
