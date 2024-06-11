#import "FrtcNewMeetingPresenter.h"
#import <FrtcManagement.h>
#import "FrtcUserModel.h"
#import "FrtcNewMeetingRoomListModel.h"
#import "YYModel.h"
#import "MBProgressHUD+Extensions.h"

@interface FrtcNewMeetingPresenter ()

@property(nonatomic, weak) id meetingView;

@end

@implementation FrtcNewMeetingPresenter

- (void)bindView:(id<FrtcNewMeetingProtocol>)view {
    _meetingView = view;
}

- (void)requestMeetingRoomList {
    [MBProgressHUD showActivityMessage:@""];
    [[FrtcManagement sharedManagement] queryMeetingRoomList:[FrtcUserModel fetchUserInfo].user_token queryMeetingRoomSuccess:^(NSDictionary * _Nonnull meetingRoom) {
        [MBProgressHUD hideHUD];
        FrtcNewMeetingRoomListModel *info = [FrtcNewMeetingRoomListModel yy_modelWithDictionary:meetingRoom];
        [self.meetingView responseMeetingRoomSuccess:info.meeting_rooms errMsg:nil];
    } queryMeetingRoomFailure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [self.meetingView responseMeetingRoomSuccess:nil errMsg:error.localizedDescription];
    }];
}

- (void)requestScheduleMeeting {
    [MBProgressHUD showActivityMessage:@""];
    NSString *meetingName = [NSString stringWithFormat:@"%@%@",[FrtcUserModel fetchUserInfo].real_name,NSLocalizedString(@"nor_new_meeting", nil)];
    [[FrtcManagement sharedManagement] scheduleMeetingWithUsertoken:[FrtcUserModel fetchUserInfo].user_token meetingName:meetingName scheduleCompletionHandler:^(NSDictionary * _Nonnull meetingInfo) {
        [MBProgressHUD hideHUD];
        FNewMeetingScheduleMeetingInfo *info = [FNewMeetingScheduleMeetingInfo yy_modelWithDictionary:meetingInfo];
        [self.meetingView responseScheduleMeetingInfoSuccess:info errMsg:nil];
    } scheduleFailure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [self.meetingView responseScheduleMeetingInfoSuccess:nil errMsg:error.localizedDescription];
    }];
}

@end
