#import <Foundation/Foundation.h>
#import "FrtcHomeMeetingDetailProtocol.h"
#import "FrtcScheduleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHomeMeetingListModel : NSObject <NSCoding,NSSecureCoding>

@property (nonatomic, copy) NSString *meetingNumber;
@property (nonatomic, copy) NSString *meetingStartTime;
@property (nonatomic, copy) NSString *meetingEndTime;
@property (nonatomic, copy) NSString *meetingName;
@property (nonatomic, copy) NSString *meetingTime;
@property (nonatomic, copy) NSString *meetingPassword;
@property (nonatomic, copy) NSString *ownerID;
@property (nonatomic, copy) NSString *ownerUserName;
@property (nonatomic, copy) NSString *meetingUrl;

@property (nonatomic, copy) NSString *groupMeetingUrl;
@property (nonatomic, copy) NSString *groupInfoKey;

@property (nonatomic, getter=isMuteMicrophone) BOOL muteMicrophone;
@property (nonatomic, getter=isMuteCamera) BOOL muteCamera;
@property (nonatomic, getter=isAudioCall) BOOL audioCall;
@property (nonatomic, getter=isPassword) BOOL password;

@property (nonatomic, assign, getter=isMeetingOperator) BOOL meetingOperator;
@property (nonatomic, assign, getter=isSystemAdmin) BOOL systemAdmin;

@property (nonatomic, getter=isRecurrence) BOOL recurrence;
@property (nonatomic, assign) FRecurrenceType recurrenceType;
@property (nonatomic, copy) NSString *recurrenceInterval_result;
@property (nonatomic, copy) NSString *meetingStartDay;
@property (nonatomic, copy) NSString *meetingEndDay;
@property (nonatomic, strong) NSArray <NSString *> *recurrenceDaysOfMonth;
@property (nonatomic, strong) NSArray <NSString *> *recurrenceDaysOfWeek;

@end



@interface FHomeDetailMeetingInfo : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@end



@interface FrtcHomeMeetingListPresenter : NSObject

- (void)bindView:(id<FrtcHomeMeetingDetailProtocol>)view;

- (void)requestHomeDetailDataWithInfo:(FHomeMeetingListModel *)model;

+ (BOOL)saveMeeting:(FHomeMeetingListModel *)model;

+ (NSArray <FHomeMeetingListModel *> *)getMeetingList;

+ (BOOL)deleteHistoryMeetingWithMeetingStartTime:(NSString *)time;

+ (BOOL)deleteAllMeeting;

@end

NS_ASSUME_NONNULL_END
