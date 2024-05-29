#import <UIKit/UIKit.h>
@class FrtcScheduleMeetingModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleTextfiledCell : UITableViewCell

@property (nonatomic, strong) FrtcScheduleMeetingModel *model;

@property (nonatomic, copy) void(^textFieldDidEndEditing)(NSString *text);

@end

NS_ASSUME_NONNULL_END
