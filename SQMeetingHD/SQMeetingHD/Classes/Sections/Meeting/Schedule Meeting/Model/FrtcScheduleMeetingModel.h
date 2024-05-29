#import <Foundation/Foundation.h>
#import "FrtcInviteUserModel.h"
#import "FrtcScheduleDetailModel.h"

@class FRecurrentMeetingResutModel;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FScheduleCellDefault = 0 ,
    FScheduleCellSwitch,
    FScheduleCellTextfiled,
    FScheduleCellNumber,
} FScheduleCellType;


@interface FrtcScheduleMeetingModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailTitle;
@property (nonatomic, getter=isShowSwitch) BOOL showSwitch;
@property (nonatomic, getter=isSwitchStatus) BOOL switchStatus;
@property (nonatomic, getter=isHideAccessView) BOOL hideAccessView;
@property (nonatomic, assign) FScheduleCellType cellType;

@property (nonatomic, getter=isEditing) BOOL edit;
@property (nonatomic, copy) NSString *personalMeetingNumber;
@property (nonatomic, copy) NSString *personalMeetingRoomId;

@property (nonatomic, strong) NSArray<FInviteUserListInfo *> *inviteUsers;
@property (nonatomic, copy) NSString *timeStamp;
@property (nonatomic, strong) NSArray *times;

@property (nonatomic, strong) FRecurrentMeetingResutModel *recurrentMeetingResultModel;
@property (nonatomic, strong) NSString *recurrence_type; //
@property (nonatomic, strong) NSString *recurrenceGroupID;
@property (nonatomic, assign) NSTimeInterval recurrenceInterval;
@property (nonatomic, strong) NSArray *recurrenceReservationList;

@end

@interface FRecurrentMeetingResutModel : NSObject

@property (nonatomic, getter=isRecurrent) BOOL recurrent;
@property (nonatomic, copy) NSString  *recurrentType;
@property (nonatomic, copy) NSString  *recurrentInterval;
@property (nonatomic, strong) NSArray *recurrentDaysOfWeek;
@property (nonatomic, strong) NSArray *recurrentDaysOfMonth;
@property (nonatomic, copy) NSString  *recurrentTitle;
@property (nonatomic, copy) NSString  *recurrentStopTime;
@property (nonatomic, copy) NSString  *stopTimeAndMeetingNumber;
@property (nonatomic, assign) FRecurrenceType recurrent_Enum_Type;

@end

NS_ASSUME_NONNULL_END
