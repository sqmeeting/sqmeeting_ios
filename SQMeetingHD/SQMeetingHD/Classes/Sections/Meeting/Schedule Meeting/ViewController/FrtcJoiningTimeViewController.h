#import "FrtcHDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrtcJoiningTimeViewController : FrtcHDBaseViewController

@property (nonatomic, copy) void(^joiningTimeResultCallBack)(NSString *time);

@property (nonatomic, copy) NSString *joiningTime;

@end

NS_ASSUME_NONNULL_END
