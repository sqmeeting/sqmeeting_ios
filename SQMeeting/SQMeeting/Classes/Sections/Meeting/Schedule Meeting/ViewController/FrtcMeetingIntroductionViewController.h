#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FScheduleIntroductionDelegate  <NSObject>
@optional
- (void)didEditIntroductionWithResult:(NSString *)info;
@end

@interface FrtcMeetingIntroductionViewController : BaseViewController

@property (nonatomic, copy) NSString *introduction;

@property (nonatomic, weak) id<FScheduleIntroductionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
