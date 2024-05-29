#import <UIKit/UIKit.h>
@class FrtcMediaStaticsModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcMeetingNetWorkView : UIView

@property (nonatomic, strong) FrtcMediaStaticsModel *staticsMediaModel;

@property (nonatomic, copy) void(^staticsInfoCallBack)(void);

@end

NS_ASSUME_NONNULL_END
