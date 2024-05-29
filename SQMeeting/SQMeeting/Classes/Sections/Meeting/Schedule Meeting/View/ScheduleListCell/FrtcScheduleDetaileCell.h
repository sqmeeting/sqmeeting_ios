#import <UIKit/UIKit.h>
@class FrtcScheduleMeetingModel;
@class FrtcScheduleCustomModel;

NS_ASSUME_NONNULL_BEGIN

#define Detail_Cell_Height 50

@interface FrtcScheduleDetaileCell : UITableViewCell

@property (nonatomic, strong) FrtcScheduleMeetingModel *model;

@property (nonatomic, strong) FrtcScheduleCustomModel *customModel;

@property (nonatomic, copy) void(^switchCallBack)(BOOL isOn);

@end

NS_ASSUME_NONNULL_END
