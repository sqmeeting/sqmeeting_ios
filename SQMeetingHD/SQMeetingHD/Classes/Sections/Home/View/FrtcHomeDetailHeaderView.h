#import <UIKit/UIKit.h>
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcHomeDetailHeaderView : UIView

@property (nonatomic, copy) void(^didSelectRecurrenceView)(void);
@property (nonatomic, strong) NSString *meetingNameText;
@property (nonatomic, getter=isRecurrent) BOOL recurrent;
@property (nonatomic, getter=isHistory) BOOL history;
@property (nonatomic, strong) FrtcScheduleDetailModel *detailModel;

@property (nonatomic, strong) UILabel *heaer_duplicateLabel;

@end

NS_ASSUME_NONNULL_END
