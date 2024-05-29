#import <UIKit/UIKit.h>
#import "FrtcMediaStaticsModel.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "FrtcStatisticalModel.h"


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const FMeetingInfoMediaStaticsInfoNotNotification;

@interface FrtcHDMeetingInfoViewController : UIViewController

@property (nonatomic, strong) FrtcMediaStaticsModel *staticsMediaModel;
@property (nonatomic, strong) FHomeMeetingListModel *meetingInfo;

@property (nonatomic, strong) FrtcStatisticalModel *staticsModel;

@end

NS_ASSUME_NONNULL_END
