#import <UIKit/UIKit.h>
@class FNewMeetingRoomListInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcScheduleNumberTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^numberSwitchCallBack)(BOOL isOn);
@property (nonatomic, copy) void(^popUpPersonalNumber)(void);

@property (nonatomic, strong) UISwitch *noiseSwitch;
@property (nonatomic, strong) NSArray <FNewMeetingRoomListInfo *> *meetingRoomList;
@property (nonatomic, strong) UIView *meetingNumberBottomView;
@property (nonatomic, strong) UITextField *meetingNumbertextField;
@property (nonatomic, strong) UIButton *rightBtn;

@end

NS_ASSUME_NONNULL_END
