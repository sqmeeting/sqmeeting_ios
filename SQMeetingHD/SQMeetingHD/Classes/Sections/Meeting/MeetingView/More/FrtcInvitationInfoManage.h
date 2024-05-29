#import <Foundation/Foundation.h>
@class FHomeMeetingListModel;
@class FrtcScheduleDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface FrtcInvitationInfoManage : NSObject

+ (void)shareInvitationInfo:(FHomeMeetingListModel *)meetinginfo;
+ (void)shareInvitationMeetingInfo:(FrtcScheduleDetailModel *)meetinginfo;


+ (NSString *)getShareInvitationInfo:(FHomeMeetingListModel *)meetinginfo;
+ (NSString *)getShareInvitationMeetingInfo:(FrtcScheduleDetailModel *)meetinginfo;

@end

NS_ASSUME_NONNULL_END
