#import <UIKit/UIKit.h>
#import "FrtcStatisticalModel.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const FMeetingInfoStaticsInfoNotification;

@interface StaticsViewController : UIViewController

@property (nonatomic, strong) FrtcStatisticalModel *staticsModel;

@property (nonatomic, copy) NSString *conferenceName;

@property (nonatomic, copy) NSString *conferenceAlias;

- (void)handleStaticsEvent:(FrtcStatisticalModel *)staticsModel;

@end

NS_ASSUME_NONNULL_END
