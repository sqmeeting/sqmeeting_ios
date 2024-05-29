#import <Foundation/Foundation.h>
#import "FrtcInviteUserModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FRecurrenceNone,
    FRecurrenceDay,
    FRecurrenceWeek,
    FRecurrenceMonth,
} FRecurrenceType;

@interface FrtcScheduleDetailModel : NSObject

@property (nonatomic, copy) NSString *reservation_id;
@property (nonatomic, copy) NSString *meeting_type;
@property (nonatomic, copy) NSString *meeting_number;
@property (nonatomic, copy) NSString *meeting_name;
@property (nonatomic, copy) NSString *call_rate_type;
@property (nonatomic, copy) NSString *recurrence_gid;
@property (nonatomic, copy) NSString *schedule_start_time;
@property (nonatomic, copy) NSString *schedule_end_time;
@property (nonatomic, copy) NSString *recurrence_type;
@property (nonatomic, assign) FRecurrenceType recurrenceType;
@property (nonatomic, copy) NSString *meeting_room_id;
@property (nonatomic, copy) NSString *meeting_password;
@property (nonatomic, copy) NSString *meeting_url;
@property (nonatomic, copy) NSString *meeting_description;
@property (nonatomic, strong) NSArray<FInviteUserListInfo *> *invited_users_details;
@property (nonatomic, copy) NSString *mute_upon_entry;
@property (nonatomic, assign) BOOL guest_dial_in;
@property (nonatomic, assign) BOOL watermark;
@property (nonatomic, copy) NSString *watermark_type;
@property (nonatomic, copy) NSString *owner_id;
@property (nonatomic, copy) NSString *owner_name;
@property (nonatomic, copy) NSString *qrcode_string;
@property (nonatomic, assign) NSInteger time_to_join;

@property (nonatomic, copy) NSString *timeKey;
@property (nonatomic, copy) NSString *start_time;
@property (nonatomic, copy) NSString *meeting_duration;
@property (nonatomic, copy) NSString *meeting_statusStr;
@property (nonatomic, copy) NSString *meeting_timeSlot;
@property (nonatomic, assign) NSInteger timeDiff;

@property (nonatomic, getter=isMuteEnty) BOOL muteEntry;
@property (nonatomic, getter=isYourSelf) BOOL yourSelf;
@property (nonatomic, getter=isOverdue)  BOOL overdue;
@property (nonatomic, getter=isInMeeting) BOOL inMeeting;
//3.3
@property (nonatomic, getter=isRecurrence) BOOL recurrence;
@property (nonatomic, getter=isJoinYourself) BOOL joinYourself;
@property (nonatomic, copy)   NSString *recurrenceGroupID;
@property (nonatomic, assign) NSInteger recurrenceInterval;
@property (nonatomic, copy)   NSString *recurrenceInterval_result;
@property (nonatomic, strong) NSArray<FrtcScheduleDetailModel *> *recurrenceReservationList;
@property (nonatomic, strong) NSArray <NSString *> *recurrenceDaysOfMonth;
@property (nonatomic, strong) NSArray <NSString *> *recurrenceDaysOfWeek;
@property (nonatomic, strong) NSString *recurrenceEndDay;
@property (nonatomic, strong) NSString *recurrenceEndTime;
@property (nonatomic, strong) NSString *recurrenceStartDay;
@property (nonatomic, strong) NSString *recurrenceStartTime;
@property (nonatomic, copy) NSString *recurrenceStopTime_str;
@property (nonatomic, copy) NSString *stopTimeAndMeetingNumber;
@property (nonatomic, strong) NSArray <NSString *> *participantUsers;
@property (nonatomic, assign) NSInteger meetingTotal_size;

@property (nonatomic, copy) NSString *groupMeetingUrl;
@property (nonatomic, copy) NSString *groupInfoKey;

@end


@interface FScheduleListDataModel : NSObject

@property (nonatomic, strong) NSArray<FrtcScheduleDetailModel *> *meeting_schedules;
@property (nonatomic, assign) NSInteger total_page_num;
@property (nonatomic, assign) NSInteger total_size;

@end

NS_ASSUME_NONNULL_END

