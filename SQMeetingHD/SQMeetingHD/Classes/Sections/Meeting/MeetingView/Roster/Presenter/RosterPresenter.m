#import "RosterPresenter.h"
#import "FrtcManagement.h"
#import "FrtcUserModel.h"
#import "MBProgressHUD+Extensions.h"
#import "FrtcManager.h"
#import "FrtcRecordAndLiveing.h"
#import "FrtcLiveAndRecordErrorModel.h"
#import "YYModel.h"
#import "UIViewController+Extensions.h"


@interface RosterPresenter ()

@property (nonatomic, weak) id rosterView;

@end

@implementation RosterPresenter

- (void)bindView:(id<RosterViewProtocol>)view {
    _rosterView = view;
}

- (void)muteAllParticipantsWithMeetingNumber:(NSString *)meetingNumber
                                 allowUnmute:(BOOL)allowUnmute {
    if (kStringIsEmpty(meetingNumber)) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] muteAllParticipants:[FrtcUserModel fetchUserInfo].user_token
                                             meetingNumber:meetingNumber
                                                      mute:allowUnmute
                                  muteAllCompletionHandler:^{
        @StrongObj(self)
        [FrtcLocalInforDefault saveYourSelf:YES];
        [self.rosterView muteAllResultWithMsg:nil];
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_START_ALLMUTE", nil)];
    } muteAllFailure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView muteAllResultWithMsg:error.localizedDescription];
    }];
}

- (void)muteParticipantWithMeetingNumber:(NSString *)meetingNumber
                             allowUnmute:(BOOL)allowUnmute
                         participantList:(NSArray<NSString *> *)participantList {
    if (kStringIsEmpty(meetingNumber)) { return; }
    if (participantList.count == 0 ) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] muteParticipant:[FrtcUserModel fetchUserInfo].user_token
                                         meetingNumber:meetingNumber
                                       allowSelfUnmute:allowUnmute
                                       participantList:participantList
                                 muteCompletionHandler:^{
        @StrongObj(self)
        [FrtcLocalInforDefault saveYourSelf:YES];
        [self.rosterView muteOneOrListResultWithMsg:nil];
    } muteAllFailure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView muteOneOrListResultWithMsg:error.localizedDescription];
    }];
}

- (void)unMuteAllParticipantsWithMeetingNumber:(NSString *)meetingNumber {
    if (kStringIsEmpty(meetingNumber)) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] unMuteAllParticipants:[FrtcUserModel fetchUserInfo].user_token
                                               meetingNumber:meetingNumber
                                    muteAllCompletionHandler:^{
        @StrongObj(self)
        [FrtcLocalInforDefault saveYourSelf:YES];
        [self.rosterView unMuteAllResultWithMsg:nil];
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_CANCEL_ALLMUTE", nil)];
    } muteAllFailure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView unMuteAllResultWithMsg:error.localizedDescription];
    }];
}

- (void)unMuteParticipantWithMeetingNumber:(NSString *)meetingNumber
                           participantList:(NSArray<NSString *> *)participantList {
    if (kStringIsEmpty(meetingNumber)) { return; }
    if (participantList.count == 0 ) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] unMuteParticipant:[FrtcUserModel fetchUserInfo].user_token
                                           meetingNumber:meetingNumber
                                         participantList:participantList
                                   muteCompletionHandler:^{
        @StrongObj(self)
        [FrtcLocalInforDefault saveYourSelf:YES];
        [self.rosterView unMuteOneOrListResultWithMsg:nil];
    } muteAllFailure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView unMuteOneOrListResultWithMsg:error.localizedDescription];
    }];
}

- (void)updateParticipantInfoWithMeetingNumber:(NSString *)meetingNumber
                                   disPlayName:(NSString *)disPlayName
                                     userToken:(NSString *)userToken
{
    if (kStringIsEmpty(meetingNumber)) { return; }
    
    if (FrtcManager.isGuestUser) {
        @WeakObj(self);
        [[FrtcManagement sharedManagement] updateParticipantInfoForGuest:meetingNumber
                                                             displayName:disPlayName
                                                              tempServer:YES
                                                             tempAddress:FrtcManager.serverAddress
                                                       completionHandler:^{
            @StrongObj(self)
            [self.rosterView updateParticipantInfoResultWithMsg:nil];
        } failure:^(NSError * _Nonnull error) {
            @StrongObj(self)
            [self.rosterView updateParticipantInfoResultWithMsg:error.localizedDescription];
        }];
    }else {
        if (isLoginSuccess) {
            @WeakObj(self);
            [[FrtcManagement sharedManagement] updateParticipantInfoForSignIn:[FrtcUserModel fetchUserInfo].user_token
                                                                meetingNumber:meetingNumber
                                                                  participant:userToken
                                                                  displayName:disPlayName
                                                            completionHandler:^{
                @StrongObj(self)
                [self.rosterView updateParticipantInfoResultWithMsg:nil];
            } failure:^(NSError * _Nonnull error) {
                @StrongObj(self)
                [self.rosterView updateParticipantInfoResultWithMsg:error.localizedDescription];
            }];
        }else {
            @WeakObj(self);
            [[FrtcManagement sharedManagement] updateParticipantInfoForGuest:meetingNumber
                                                                 displayName:disPlayName
                                                                  tempServer:NO
                                                                 tempAddress:FrtcManager.serverAddress
                                                           completionHandler:^{
                @StrongObj(self)
                [self.rosterView updateParticipantInfoResultWithMsg:nil];
            } failure:^(NSError * _Nonnull error) {
                @StrongObj(self)
                [self.rosterView updateParticipantInfoResultWithMsg:error.localizedDescription];
            }];
        }
    }
}

- (void)setLecturerWithMeetingNumber:(NSString *)meetingNumber
                         participant:(NSString *)participant {
    if (kStringIsEmpty(meetingNumber)) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] setLecturer:[FrtcUserModel fetchUserInfo].user_token
                                      lecturerUUID:participant
                                     meetingNumber:meetingNumber
                                 completionHandler:^{
        @StrongObj(self)
        [self.rosterView setLecturerResultWithMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView setLecturerResultWithMsg:error.localizedDescription];
    }];
    
}

- (void)unSetLecturerWithMeetingNumber:(NSString *)meetingNumber {
    if (kStringIsEmpty(meetingNumber)) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] unsetLecturer:[FrtcUserModel fetchUserInfo].user_token
                                       meetingNumber:meetingNumber
                                   completionHandler:^{
        @StrongObj(self)
        [self.rosterView unSetLecturerResultWithMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView unSetLecturerResultWithMsg:error.localizedDescription];
    }];
    
}

- (void)disconnectParticipantsWithMeetingNumber:(NSString *)meetingNumber
                                participantList:(NSArray<NSString *> *)participantList {
    
    if (kStringIsEmpty(meetingNumber)) { return; }
    if (participantList.count == 0 ) { return; }
    @WeakObj(self);
    [[FrtcManagement sharedManagement] disConnectParticipants:[FrtcUserModel fetchUserInfo].user_token
                                                meetingNumber:meetingNumber
                                              participantList:participantList
                                            completionHandler:^{
        @StrongObj(self)
        [self.rosterView disconnectParticipantsResultWithMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView disconnectParticipantsResultWithMsg:error.localizedDescription];
    }];
    
}

- (void)startTextOverlayWithMeetingNumber:(NSString *)meetingNumber
                                  content:(NSString *)content
                                   repeat:(NSNumber *)repeat
                                 position:(NSNumber *)position
                            enable_scroll:(NSNumber *)enable {
    @WeakObj(self);
    [[FrtcManagement sharedManagement] startTextOverlay:[FrtcUserModel fetchUserInfo].user_token
                                          meetingNumber:meetingNumber
                                                content:content
                                                 repeat:repeat
                                               position:position
                                          enable_scroll:enable
                                      completionHandler:^{
        @StrongObj(self)
        [self.rosterView startTextOverlayResultWithMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        @StrongObj(self)
        [self.rosterView startTextOverlayResultWithMsg:error.localizedDescription];
    }];
    
    
}

- (void)stopTextOverlayWithMeetingNumber:(NSString *)meetingNumber {
    [[FrtcManagement sharedManagement] stopTextOverlay:[FrtcUserModel fetchUserInfo].user_token
                                         meetingNumber:meetingNumber
                                     completionHandler:^{
        [MBProgressHUD showMessage:NSLocalizedString(@"meeting_overlay_stop", nil)];
    } failure:^(NSError * _Nonnull error) {
      
    }];
}

- (void)startRecordingWithMeetingNumber:(NSString *)meetingNumber {
    [[FrtcManagement sharedManagement] startRecording:[FrtcUserModel fetchUserInfo].user_token meetingNumber:meetingNumber completionHandler:^{
    } failure:^(NSError * _Nonnull error) {
        [self handleRecordingAndLiveingError:error];
    }];
}

- (void)stopRecordingWithMeetingNumber:(NSString *)meetingNumber{
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindow.rootViewController showAlertWithTitle:NSLocalizedString(@"MEETING_STOP_RECORD_TITLE", nil) message:NSLocalizedString(@"MEETING_STOP_RECORD_MESSAGE", nil) buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"meeting_stop_record", nil)] alerAction:^(NSInteger index) {
        if (index == 1) {
            [[FrtcManagement sharedManagement] stopRecording:[FrtcUserModel fetchUserInfo].user_token meetingNumber:meetingNumber completionHandler:^{
                [MBProgressHUD showMessage:NSLocalizedString(@"FM_VIDEO_RECORDING_STOP_REMINDER", @"Recording ended")];
            } failure:^(NSError * _Nonnull error) {
                [self handleRecordingAndLiveingError:error];
            }];
        }
    }];
}

- (void)startLiveWithMeetingNumber:(NSString *)meetingNumber livePassword:(NSString *)livePassword {
    [[FrtcManagement sharedManagement] startLive:[FrtcUserModel fetchUserInfo].user_token meetingNumber:meetingNumber livePassword:livePassword completionHandler:^{
        
    } failure:^(NSError * _Nonnull error) {
        [self handleRecordingAndLiveingError:error];
    }];
}

- (void)stopLiveWithMeetingNumber:(NSString *)meetingNumber {
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindow.rootViewController showAlertWithTitle:NSLocalizedString(@"MEETING_STOP_LIVE_TITLE", nil) message:@"" buttonTitles:@[NSLocalizedString(@"dialog_cancel", nil),NSLocalizedString(@"meeting_stop_live", nil)] alerAction:^(NSInteger index) {
        if (index == 1) {
            [[FrtcManagement sharedManagement] stopLive:[FrtcUserModel fetchUserInfo].user_token meetingNumber:meetingNumber completionHandler:^{
                [MBProgressHUD showMessage:NSLocalizedString(@"FM_VIDEO_STREAMING_STOP_REMINDER", @"Live ended")];
            } failure:^(NSError * _Nonnull error) {
                [self handleRecordingAndLiveingError:error];
            }];
        }
    }];
}

- (void)toastString:(NSString *)errorCode {
    NSString *errorMessage = @"";
    if ([errorCode isEqualToString:RECORDING_START_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_START_ERROR", @"Start recording error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:RECORDING_PARAM_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_PARAM_ERROR", @"Recording parameter error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:RECORDING_LICENSE_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_LICENSE_ERROR", @"The service is not licensed or the license has expired.");
        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_RECORDING_FAILED_TITLE", @"Recording failed") message:errorMessage buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) { }];
    } else if ([errorCode isEqualToString:RECORDING_LICENSE_FULL_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_LICENSE_FULL_ERROR", @"The recording users has reached the maximum, please upgrade the software license.");
        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_RECORDING_FAILED_TITLE", @"Recording failed") message:errorMessage buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) { }];
    } else if ([errorCode isEqualToString:RECORDING_SOURCE_FULL_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_SOURCE_FULL_ERROR", @"The recording server resource is insufficient, please contact the system administrator.");
        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_RECORDING_FAILED_TITLE", @"Recording failed") message:errorMessage buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) { }];
    } else if ([errorCode isEqualToString:RECORDING_NOT_EXIT_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_NOT_EXIT_ERROR", @"The recording server does not exist");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:RECORDING_NOT_REPEATE_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_NOT_REPEATE_ERROR", @"Cannot start recording repeatedly");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:RECORDING_STOP_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_STOP_ERROR", @"End recording error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:RECORDING_STOP_PARAM_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_RECORDING_STOP_PARAM_ERROR", @"End recording parameter error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:STREAMING_START_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_START_ERROR", @"Start live streaming error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:STREAMING_PARAM_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_PARAM_ERROR", @"Live streaming parameter error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:STREAMING_LICENSE_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_LICENSE_ERROR", @"The service is not licensed or the license has expired.");
        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_STREAMING_FAILED_TITLE", @"Live streaming failed") message:errorMessage buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) { }];
    } else if ([errorCode isEqualToString:STREAMING_LICENSE_FULL_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_LICENSE_FULL_ERROR",@"The live streaming  users has reached the maximum, please upgrade the software license.");
        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_STREAMING_FAILED_TITLE", @"Live streaming failed") message:errorMessage buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) { }];
    } else if ([errorCode isEqualToString:STREAMING_SOURCE_FULL_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_SOURCE_FULL_ERROR",@"The live streaming server resource is insufficient, please contact the system administrator.");
        [[FrtcHelpers getCurrentVC] showAlertWithTitle:NSLocalizedString(@"FM_VIDEO_STREAMING_FAILED_TITLE", @"Live streaming failed") message:errorMessage buttonTitles:@[NSLocalizedString(@"string_ok", nil)] alerAction:^(NSInteger index) { }];
    } else if ([errorCode isEqualToString:STREAMING_NOT_EXIT_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_NOT_EXIT_ERROR",@"The live streaming server does not exist");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:STREAMING_NOT_REPEATE_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_NOT_REPEATE_ERROR",@"Cannot start live streaming repeatedly");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:STREAMING_STOP_ERROR]) {
        errorMessage = NSLocalizedString(@"FM_VIDEO_STREAMING_STOP_ERROR",@"End live streaming error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:STREAMING_STOP_PARAM_ERROR]) {
        errorMessage = NSLocalizedString( @"FM_VIDEO_STREAMING_STOP_PARAM_ERROR",@"End live streaming parameter error");
        [self showReminderView:errorMessage];
    } else if ([errorCode isEqualToString:RECORDING_SERVICE_ERROR]) {
        errorMessage = NSLocalizedString( @"RECORDING_SERVICE_ERROR",nil);
        [self showReminderView:errorMessage];
    }
}

- (void)handleRecordingAndLiveingError:(NSError *)error {
    NSDictionary *erroInfo = error.userInfo;
    NSData *data = [erroInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
    NSString *errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ISMLog(@"errorString = %@",errorString);
    FrtcLiveAndRecordErrorModel *failureModel = [FrtcLiveAndRecordErrorModel yy_modelWithJSON:errorString];
    [self toastString:failureModel.errorCode];
}

- (void)showReminderView:(NSString *)stringValue {
    [MBProgressHUD showMessage:stringValue];
}

- (void)requestUnmuteWithMeetingNumber:(NSString *)meetingNumber {
    if (FrtcManager.isGuestUser) {
        [[FrtcManagement sharedManagement] requestUnmuteForGuest:@""
                                                   meetingNumber:meetingNumber
                                                     tempAddress:FrtcManager.serverAddress
                                               completionHandler:^{
            [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_CELLVIEW_REQUESTSEND", nil)];
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:NSLocalizedString(@"network_error", nil)];
        }];
    }else{
        [[FrtcManagement sharedManagement] requestUnmute:[FrtcUserModel fetchUserInfo].user_token
                                           meetingNumber:meetingNumber
                                       completionHandler:^{
            [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_CELLVIEW_REQUESTSEND", nil)];
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:NSLocalizedString(@"network_error", nil)];
        }];
    }
}

- (void)allowUnmuteWithMeetingNumber:(NSString *)meetingNumber parameters:(NSArray<NSString *> *)parameters {
    [[FrtcManagement sharedManagement] allowUnmute:[FrtcUserModel fetchUserInfo].user_token
                                     meetingNumber:meetingNumber
                                        parameters:parameters
                                 completionHandler:^{
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_CELLVIEW_MESSAGE", nil)];
        [self.rosterView requestUnmuteResultMsg:nil];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:NSLocalizedString(@"network_error", nil)];
        [self.rosterView requestUnmuteResultMsg:error.localizedDescription];
    }];
}

- (void)pinParticipantWithMeetingNumber:(NSString *)meetingNumber
                             parameters:(NSArray<NSString *> *)parameters {
    
    [[FrtcManagement sharedManagement] peoplePin:[FrtcUserModel fetchUserInfo].user_token
                                   meetingNumber:meetingNumber
                                      parameters:parameters
                               completionHandler:^{
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_PIN_SUCCESS", nil)];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:NSLocalizedString(@"network_error", nil)];
    }];;
}

- (void)unPinParticipantWithMeetingNumber:(NSString *)meetingNumber {
    
    [[FrtcManagement sharedManagement] peopleUnPin:[FrtcUserModel fetchUserInfo].user_token
                                     meetingNumber:meetingNumber
                                 completionHandler:^{
        [MBProgressHUD showMessage:NSLocalizedString(@"MEETING_ROSTER_LISTVIEW_UNPIN_SUCCESS", nil)];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:NSLocalizedString(@"network_error", nil)];
    }];
}

@end

