#import <UIKit/UIKit.h>
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

#define HomeScheduleCellHeight 72.0

@interface FrtcHomeScheduleCell : UITableViewCell

@property (nonatomic, strong) FrtcScheduleDetailModel *scheduledInfo;

@end

NS_ASSUME_NONNULL_END
