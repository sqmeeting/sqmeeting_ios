#import <UIKit/UIKit.h>
@class FHomeDetailMeetingInfo;

NS_ASSUME_NONNULL_BEGIN

#define KHomeDtailCellHeight 60

@interface FrtcHomeDetailTableViewCell : UITableViewCell

@property (nonatomic, strong) FHomeDetailMeetingInfo *info;

@end

NS_ASSUME_NONNULL_END