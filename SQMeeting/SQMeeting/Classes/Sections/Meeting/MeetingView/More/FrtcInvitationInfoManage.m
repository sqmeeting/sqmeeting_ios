#import "FrtcInvitationInfoManage.h"
#import "FrtcHomeMeetingListPresenter.h"
#import "MBProgressHUD+Extensions.h"
#import "UIView+Toast.h"
#import "FrtcUserModel.h"
#import "FrtcScheduleDetailModel.h"
#import "FrtcMeetingRecurrenceDateManager.h"

@implementation FrtcInvitationInfoManage

+ (void)shareInvitationInfo:(FHomeMeetingListModel *)meetinginfo {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self getShareInvitationInfo:meetinginfo];
    [MBProgressHUD showMessage:NSLocalizedString(@"meeting_copy_success", nil)];
}

+ (void)shareInvitationMeetingInfo:(FrtcScheduleDetailModel *)meetinginfo {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self getShareInvitationInfo:[self getShareMeetingInfo:meetinginfo]];
    [MBProgressHUD showMessage:NSLocalizedString(@"meeting_copy_success", nil)];
}

+ (NSString *)getShareInvitationMeetingInfo:(FrtcScheduleDetailModel *)meetinginfo {
    return [self getShareInvitationInfo:[self getShareMeetingInfo:meetinginfo]];
}

+ (FHomeMeetingListModel *)getShareMeetingInfo:(FrtcScheduleDetailModel *)detailMneetigInfo {
    FHomeMeetingListModel *meetingInfo = [FHomeMeetingListModel new];
    meetingInfo.meetingName = detailMneetigInfo.meeting_name;
    meetingInfo.meetingUrl = detailMneetigInfo.meeting_url;
    meetingInfo.meetingNumber = detailMneetigInfo.meeting_number;
    meetingInfo.meetingPassword = detailMneetigInfo.meeting_password;
    meetingInfo.ownerID = detailMneetigInfo.owner_id;
    meetingInfo.ownerUserName = detailMneetigInfo.owner_name;
    meetingInfo.meetingStartTime = detailMneetigInfo.schedule_start_time;
    meetingInfo.meetingEndTime = detailMneetigInfo.schedule_end_time;
    meetingInfo.recurrence = detailMneetigInfo.recurrence;
    meetingInfo.meetingStartDay = detailMneetigInfo.recurrenceStartDay;
    meetingInfo.meetingEndDay = detailMneetigInfo.recurrenceEndDay;
    meetingInfo.recurrenceInterval_result = detailMneetigInfo.recurrenceInterval_result;
    meetingInfo.groupInfoKey = detailMneetigInfo.groupInfoKey;
    meetingInfo.groupMeetingUrl = detailMneetigInfo.groupMeetingUrl;
    meetingInfo.recurrenceDaysOfWeek = detailMneetigInfo.recurrenceDaysOfWeek;
    meetingInfo.recurrenceDaysOfMonth = detailMneetigInfo.recurrenceDaysOfMonth;
    meetingInfo.recurrenceType = detailMneetigInfo.recurrenceType;
    return meetingInfo;
}

+ (NSString *)getShareInvitationInfo:(FHomeMeetingListModel *)meetinginfo {
    
    NSMutableString *meetingInfoCopy = [NSMutableString stringWithCapacity:10];
    
    NSString *userName = [FrtcUserModel fetchUserInfo].real_name;
    [meetingInfoCopy appendFormat:@"%@ %@ \n",(kStringIsEmpty(userName) ? @"" : userName),NSLocalizedString(@"share_invitation", nil)];
    
    NSString *meetingName = [NSString stringWithFormat:@"%@: %@ \n",NSLocalizedString(@"meeting_theme", nil),meetinginfo.meetingName];
    [meetingInfoCopy appendFormat:@"%@",meetingName];
    
    if (!kStringIsEmpty(meetinginfo.meetingStartTime) && [meetinginfo.meetingStartTime intValue] != 0) {
        NSString *meetingStartTime = [NSString stringWithFormat:@"%@: %@ \n",NSLocalizedString(@"meeting_start_time", nil),[FrtcHelpers getDateStringWithTime:meetinginfo.meetingStartTime]];
        [meetingInfoCopy appendFormat:@"%@",meetingStartTime];
    }
    
    if (!kStringIsEmpty(meetinginfo.meetingEndTime)  && [meetinginfo.meetingEndTime intValue] != 0) {
        NSString *meetingEndTime = [NSString stringWithFormat:@"%@: %@ \n",NSLocalizedString(@"meeting_end_time", nil),[FrtcHelpers getDateStringWithTime:meetinginfo.meetingEndTime]];
        [meetingInfoCopy appendFormat:@"%@",meetingEndTime];
    }
    
    NSString *meetingNumber = [NSString stringWithFormat:@"%@: %@ \n",NSLocalizedString(@"meeting_id", nil),meetinginfo.meetingNumber];
    [meetingInfoCopy appendFormat:@"%@",meetingNumber];
    
    if (meetinginfo.isRecurrence) {
        NSString *recurrenceDays = @"";
        if (meetinginfo.recurrenceType == FRecurrenceWeek) {
            recurrenceDays = [NSString stringWithFormat:@"(%@)",f_weekRecurrenceDate(f_convertToChineseWeekday(meetinginfo.recurrenceDaysOfWeek))];
        }else if (meetinginfo.recurrenceType == FRecurrenceMonth) {
            recurrenceDays = [NSString stringWithFormat:@"(%@)",f_monthRecurrenceDate(meetinginfo.recurrenceDaysOfMonth)];
        }
        
        NSString *recurrenceStr = [NSString stringWithFormat:@"%@: %@ - %@, %@ %@ \n",FLocalized(@"recurrence_meeting", nil),[FrtcHelpers getDateCustomStringWithTimeStr:meetinginfo.meetingStartDay],[FrtcHelpers getDateCustomStringWithTimeStr:meetinginfo.meetingEndDay],meetinginfo.recurrenceInterval_result,recurrenceDays];
        [meetingInfoCopy appendFormat:@"%@",recurrenceStr];
    }
    
    if (!kStringIsEmpty(meetinginfo.meetingPassword)) {
        NSString *meetingpsd = [NSString stringWithFormat:@"%@: %@ \n",NSLocalizedString(@"string_pwd", nil),meetinginfo.meetingPassword];
        [meetingInfoCopy appendFormat:@"%@",meetingpsd];
        [meetingInfoCopy appendFormat:@"\n%@",NSLocalizedString(@"share_content", nil)];
    }else{
        [meetingInfoCopy appendFormat:@"\n%@",NSLocalizedString(@"share_content_nopwd", nil)];
    }
    
    if (meetinginfo.isRecurrence) {
        if (!kStringIsEmpty(meetinginfo.groupMeetingUrl)) {
            NSString *meetingShareUrl = [NSString stringWithFormat:@"\n%@\n%@ \n",NSLocalizedString(@"meeting_sahre_url_join", nil),meetinginfo.groupMeetingUrl];
            [meetingInfoCopy appendFormat:@"%@",meetingShareUrl];
        }
    }else{
        if (!kStringIsEmpty(meetinginfo.meetingUrl)) {
            NSString *meetingShareUrl = [NSString stringWithFormat:@"\n%@\n%@ \n",NSLocalizedString(@"meeting_sahre_url_join", nil),meetinginfo.meetingUrl];
            [meetingInfoCopy appendFormat:@"%@",meetingShareUrl];
        }
    }
    return meetingInfoCopy;
}

@end

