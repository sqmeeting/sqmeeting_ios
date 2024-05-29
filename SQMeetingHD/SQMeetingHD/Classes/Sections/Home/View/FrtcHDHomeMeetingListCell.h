#import <UIKit/UIKit.h>
@class FHomeMeetingListModel;
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

#define HomeMeetingListCellHeight 72.0

@interface FrtcHDHomeMeetingListCell : UITableViewCell

@property (nonatomic, strong) FHomeMeetingListModel *info;
@property (nonatomic, strong) FrtcScheduleDetailModel *scheduledInfo;

@end

NS_ASSUME_NONNULL_END
