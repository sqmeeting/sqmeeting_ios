#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kFrtcCallShared [FrtcCall frtcSharedCallClient]

@class UIViewController;

FOUNDATION_EXPORT NSString * const FMeetingUIDisappearOrNotNotification;
FOUNDATION_EXPORT NSString * const FMeetingUIDisappearOrNotKey;

FOUNDATION_EXPORT NSString * const FMeetingParticipantsListKey;
FOUNDATION_EXPORT NSString * const FMeetingParticipantsListKeyNotification;

FOUNDATION_EXPORT NSString * const FMeetingContentStopNotification;

typedef NS_ENUM(NSUInteger, FMeetingUIDisappearOrNot) {
    FMeetingUIDisappear = 0,
    FMeetingUIAppear = 1,
};

typedef NS_ENUM(NSInteger, FRTCMeetingStatus) {
    MEETING_STATUS_IDLE,
    MEETING_STATUS_CONNECTE,
    MEETING_STATUS_DISCONNECTED,
};

typedef NS_ENUM(NSInteger, FRTCMeetingStatusReason) {
    MEETING_STATUS_SUCCESS,
    MEETING_STATUS_MEETINGNOTEXIST,
    MEETING_STATUS_REJECTED,
    MEETING_STATUS_NOANSWER,
    MEETING_STATUS_UNREACHABLE,
    MEETING_STATUS_HABGUP,
    MEETING_STATUS_ABORTED,
    MEETING_STATUS_LOSTCONNECTION,
    MEETING_STATUS_LOCKED,
    MEETING_STATUS_SERVERERROR,
    MEETING_STATUS_NOPERMISSION,
    MEETING_STATUS_AUTHFAILED,
    MEETING_STATUS_UNABLEPROCESS,
    MEETING_STATUS_FAILED,
    MEETING_STATUS_CONNECTED,
    MEETING_STATUS_STOP,
    MEETING_STATUS_INTERRUPT,
    MEETING_STATUS_REMOVE,
    MEETING_STATUS_PASSWORD_TOO_MANY_RETRIES,
    MEETING_STATUS_EXPIRED,
    MEETING_STATUS_NOT_STARTED,
    MEETING_STATUS_GUEST_UNALLOWED,
    MEETING_STATUS_PEOPLE_FULL,
    MEETING_STATUS_NO_LICENSE,
    MEETING_STATUS_LICENSE_MAX_LIMIT_REACHED,
    MEETING_STATUS_EXIT_EXCEPTION,
    MEETING_STATUS_END_ABNORMAL
};

typedef struct {
    NSString *conferenceNumber;
    NSString *clientName;
    NSString *userToken;
    NSString *password;
    NSString *callUrl;
    int callRate;
    BOOL muteMicrophone;
    BOOL muteCamera;
    BOOL audioCall;
    BOOL floatWindow;
    BOOL sharing;
} FRTCSDKCallParam;

typedef struct {
    NSString *conferenceName;
    NSString *conferenceAlias;
    NSString *ownerID;
    NSString *ownerName;
    NSString *meetingUrl;
    NSString *groupMeetingUrl;
    long long scheduleStartTime;
    long long scheduleEndTime;
} FRTCMeetingStatusSuccessParam;


@protocol FrtcCallDelegate <NSObject>

@optional

- (void)onMeetingMessage:(NSString *)message;

- (void)onParticipantsList:(NSMutableArray<NSDictionary *>  *)rosterList;

- (void)onParticipantsNumber:(NSInteger)participantsNumber;

- (void)onRostList:(NSString *)rostListString;

- (void)onLectureList:(NSMutableArray<NSString *> *)lectureListArray;

- (void)onPinStatus:(BOOL)pinStatus;

- (void)onMute:(BOOL)mute allowSelfUnmute:(BOOL)allowSelfUnmute;

- (void)onReceiveUnmuteRequest:(NSMutableDictionary *)requestUnmuteDictionary;

- (void)onReceiveAllowUnmute;

- (void)onContentState:(NSInteger)state;

- (void)onNetworkStateChanged:(NSInteger)state;

- (void)onRecordingLiveStateChange:(NSDictionary *)resultDictionary;

- (void)onDidChangeOrientation:(BOOL)isPortrait;

- (void)onPeopleVideoPinList:(NSArray *)pinList;

@end

typedef void (^FRTCSDKCallCompletionHandler)(FRTCMeetingStatus callMeetingStatus,
                                             FRTCMeetingStatusReason reason,
                                             FRTCMeetingStatusSuccessParam callSuccessParam, 
                                             UIViewController * _Nullable meetingViewController);

@interface FrtcCall:NSObject

@property (nonatomic, weak) id<FrtcCallDelegate> callDelegate;
@property (nonatomic, assign, getter = isFloatWindow) BOOL floatWindow;

+ (FrtcCall *)frtcSharedCallClient;

- (void)frtcMakeCall:(FRTCSDKCallParam)callParam
          controller:(UIViewController * _Nonnull)controller
      callCompletion:(FRTCSDKCallCompletionHandler)callCompletionHandler
     requestPassword:(void(^)(void))requestMeetingPassword
      contentRequest:(void(^)(void))contentRequest;

- (NSString *)frtcGetCurrentVersion;

- (void)frtcHangupCall;

- (void)frtcMuteLocalCamera:(BOOL)mute;

- (BOOL)frtcGetCurrentVideoMuteStatus;

- (BOOL)frtcGetCurrentAudioMuteStatus;

- (void)frtcMuteLocalMicPhone:(BOOL)mute;

- (NSString *)frtcGetCallStaticsInfomation;

- (void)frtcSendCallPasscode:(NSString *)passcode;

- (void)frtcHiddenLocalPreView:(BOOL)hidden;

- (void)frtcSwitchCameraPosition;

- (void)frtcChangeSpeakerStatus:(BOOL)isSpeaker;

- (void)frtcIntelligentDenoise:(BOOL)isDenoise;

- (void)frtcShareContent:(BOOL)isShareContent;

- (NSString *)frtcGetClientUUID;

- (NSInteger)frtcStartUploadLogs:(NSString *)metaData
                    fileName:(NSString *)fileName
                   fileCount:(int)fileCount;

- (NSString *)frtcGetUploadStatus:(int)tractionId fileType:(int)fileType;;

- (void)frtcCancelUploadLogs:(int)tractionId;

- (void)frtcMuteRemotePeopleVideo:(BOOL)mute;

- (BOOL)frtcGetCurrentRemotePeopleVideoMuteStatus;

- (void)frtcFloatingMeetingWindow:(BOOL)isSharing;

- (void)frtcCloseMeetingView;

- (void)frtcChangeFloatWindowFrame;

- (void)frtcChangeFloatButtonTitle:(NSString *)title;

- (void)f_InfoLog:(NSString *)log;

NS_ASSUME_NONNULL_END

@end

