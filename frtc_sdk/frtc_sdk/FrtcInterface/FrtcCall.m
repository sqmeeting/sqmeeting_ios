#include "FrtcCall.h"
#import <UIKit/UIKit.h>
#import "FrtcMeetingViewController.h"
#import "FrtcAudioClient.h"
#import "CaptureCameraStream.h"
#import "ObjectInterface.h"
#import "FrtcMeetingStatusMachineTransition.h"
#import "NSTimer+Enhancement.h"
#import "SDKUserDefault.h"
#import "NSData+AESTest.h"
#import "GTMBase64.h"
#import "ContentCaptureAdaper.h"
#import "FrtcUUID.h"
#import "FrtcUIMacro.h"
#import "FrtcFloatingWindow.h"
#import "FrtcCustomNavViewController.h"
#include "log.h"

#define kHiddenProportion 0.14545455

#define kEndAbnormalTag 49
#define kIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )

NSString * const FMeetingUIDisappearOrNotNotification = @"com.fmeeting.meetingui.disappear";
NSString * const FMeetingUIDisappearOrNotKey = @"com.fmeeting.meetingui.disappear.key";

NSString * const FMeetingParticipantsListKey = @"com.fmeeting.participant.list.key";
NSString * const FMeetingParticipantsListKeyNotification = @"com.fmeeting.participants.list";

NSString * const FMeetingContentStopNotification = @"com.fmeeting.content.stop";

NSString * const key = @"aab7097c02c0493093755c734d150aaf";

typedef void (^SDKInputPasswordBlock)();
typedef void (^SDKContentRequestBlock)();

static FrtcCall *clientWrapper = nil;

@interface FrtcCall()

@property (nonatomic) FRTCMeetingStatus meetingStatus;

@property (nonatomic, weak) UIViewController *parentViewController;

@property (nonatomic, copy) NSString *clientName;
@property (nonatomic, copy) NSString *conferenceName;
@property (nonatomic, copy) NSString *conferenceAlias;
@property (nonatomic, copy) NSString *overLayMessage;
@property (nonatomic, copy) NSString *serverAddress;
@property (nonatomic, copy) NSString *ownerID;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *meetingUrl;
@property (nonatomic, copy) NSString *groupMeetingUrl;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *meetingRecordingStatus;
@property (nonatomic, copy) NSString *meetingLiveStatus;
@property (nonatomic, copy) NSString *meetingLiveMeetingUrl;
@property (nonatomic, copy) NSString *meetingLiveMeetingPwd;
@property (nonatomic, assign) long long scheduleStartTime;
@property (nonatomic, assign) long long scheduleEndTime;
@property (nonatomic, strong) NSMutableArray * _Nullable meetingStatusMachines;

@property (nonatomic, copy) FRTCSDKCallCompletionHandler completionHandler;
@property (nonatomic, copy) SDKInputPasswordBlock passwordBlock;
@property (nonatomic, copy) SDKContentRequestBlock contentRequestCallBack;

@property (nonatomic, assign, getter = isAudioCall) BOOL audioCall;
@property (nonatomic, assign, getter = isMuteCamera) BOOL muteCamera;
@property (nonatomic, assign, getter = isMuteMicrophone) BOOL muteMicrophone;
@property (nonatomic, assign, getter = isReconnect) BOOL reconnect;
@property (nonatomic, assign, getter = isMuteRemotePeopleVideo) BOOL muteRemotePeopleVideo;

@property (nonatomic, assign, getter = isTempMuteCamera) BOOL tempMuteCamera;
@property (nonatomic, assign, getter = isTempMuteRemotePeopleVideo) BOOL tempMuteRemotePeopleVideo;

@property (nonatomic, copy) NSString *waterMarkString;

@property (nonatomic) int reason;

@property (strong, nonatomic) NSTimer  *waitCallTimer;

@property (nonatomic, strong) FrtcFloatingWindow *floatingWindow;
@property (nonatomic, strong) FrtcMeetingViewController *meetingVC;
@property (nonatomic, strong) UIButton *meetingButton;
@property (nonatomic, assign, getter = isSharing) BOOL sharing;

@end

@implementation FrtcCall

+ (FrtcCall *)frtcSharedCallClient {
    @synchronized(self) {
        if (clientWrapper == nil) {
            clientWrapper = [[FrtcCall alloc] init];
        }
    }
    
    return clientWrapper;
}

- (id)init {
    if(self = [super init]) {
        _meetingStatus = MEETING_STATUS_IDLE;
        _meetingStatusMachines = [NSMutableArray array];
        [self setupCallStateTransition];
    }
    
    return self;
}

- (void)setupStateMachine:(FRTCMeetingStatus)theCurState newState:(FRTCMeetingStatus)theNewState andAction:(SDKCallStateAction)theAction {
    FrtcMeetingStatusMachineTransition* transition = [[FrtcMeetingStatusMachineTransition alloc] initWithCurrentCallState:theCurState newCallState:theNewState andAction:theAction];
    [self.meetingStatusMachines addObject:transition];
}

- (void)setupCallStateTransition {
    __weak __typeof(self)weakSelf = self;
    [self setupStateMachine:MEETING_STATUS_IDLE
                   newState:MEETING_STATUS_IDLE
                  andAction:^{
        
    }];
    
    [self setupStateMachine:MEETING_STATUS_IDLE
                   newState:MEETING_STATUS_CONNECTE
                  andAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [weakSelf presentCallView];
        });
        
    }];
    
    [self setupStateMachine:MEETING_STATUS_IDLE
                   newState:MEETING_STATUS_DISCONNECTED
                  andAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dismissView];
        });
    }];
    
    
    [self setupStateMachine:MEETING_STATUS_CONNECTE
                   newState:MEETING_STATUS_CONNECTE
                  andAction:^{
        
    }];
    
    [self setupStateMachine:MEETING_STATUS_CONNECTE
                   newState:MEETING_STATUS_DISCONNECTED
                  andAction:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf callDisconnected];
    }];
    
    [self setupStateMachine:MEETING_STATUS_DISCONNECTED
                   newState:MEETING_STATUS_CONNECTE
                  andAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [weakSelf presentCallView];
        });
    }];
    
    [self setupStateMachine:MEETING_STATUS_DISCONNECTED
                   newState:MEETING_STATUS_DISCONNECTED
                  andAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dismissView];
        });
    }];
}

- (void)presentCallView {
    if (self.isReconnect) {
        [kFrtcCallShared f_InfoLog:@"[reconnect] reconnect"];
        [self callConnected];
        self.reconnect = NO;
    }else{
        [self showCallWindow];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self callConnected];
        });
    }
}

- (void)showCallWindow {
    self.floatingWindow = [[FrtcFloatingWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    self.meetingVC = [[FrtcMeetingViewController alloc] init];
    self.meetingVC.callDelegate = self.callDelegate;
    self.meetingVC.meetingModel = [[FrtcMeetingModel alloc]init];
    self.meetingVC.meetingModel.callName          = self.clientName;
    self.meetingVC.meetingModel.muteCamera        = self.muteCamera;
    self.meetingVC.meetingModel.muteMicrophone    = self.muteMicrophone;
    self.meetingVC.meetingModel.conferenceAlias   = self.conferenceAlias;
    self.meetingVC.meetingModel.conferenceName    = self.conferenceName;
    self.meetingVC.meetingModel.messageOverLay    = self.overLayMessage;
    self.meetingVC.meetingModel.audioCall         = self.audioCall;
    self.meetingVC.meetingModel.floatSharing      = self.isSharing;
    
    self.meetingVC.meetingModel.meetingLiveStatus      = _meetingLiveStatus;
    self.meetingVC.meetingModel.meetingRecordingStatus = _meetingRecordingStatus;
    self.meetingVC.meetingModel.meetingLiveMeetingUrl  = _meetingLiveMeetingUrl;
    self.meetingVC.meetingModel.meetingLiveMeetingPwd  = _meetingLiveMeetingPwd;
    
    [self.meetingVC waterPrint:self.waterMarkString];
    
    @WeakObj(self)
    self.meetingVC.onDidChangeOrientation = ^{
        @StrongObj(self)
        [self onDidChangeOrientation];
    };
    
    FrtcCustomNavViewController *navigation = [[FrtcCustomNavViewController alloc]initWithRootViewController:self.meetingVC];
    self.floatingWindow.rootViewController = navigation;
    [self.floatingWindow setHidden:NO];
    
    if (self.isFloatWindow) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self frtcFloatingMeetingWindow:self.isSharing];
        });
    }
}

- (void)callConnected {
    [[FrtcAudioClient sharedAudioUnitCapture] enableAudioUnitCoreGraph];
    if (self.isReconnect) {
        [[ObjectInterface sharedObjectInterface] muteLocalAudioObject:self.isMuteMicrophone];
    }
    InfoLog("[ ] callConnected");
    FRTCMeetingStatusReason status = MEETING_STATUS_CONNECTED;
    self.completionHandler(MEETING_STATUS_CONNECTE, status, [self generateSuccessCallResultParam], self.meetingVC);
}

- (void)callDisconnected {
    InfoLog("[ ] callDisconnected");
    [[FrtcAudioClient sharedAudioUnitCapture] disableAudioUnitCoreGraph];
    [[CaptureCameraStream SingletonInstance] removeVideoSession];
    self.waterMarkString = @"";
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[self presentedViewController] stopRender];
        [weakSelf dismissView];
    });
}

- (void)dismissView {
    FRTCMeetingStatusReason status = [self meetingStatusReason:self.reason];
    InfoLog("[iOS dismiss] dismissView begin");
    if (self.isReconnect) {
        InfoLog("[iOS dismiss] dismissView reconnecting");
        return;
    }
    if (status == MEETING_STATUS_END_ABNORMAL) {
        InfoLog("[iOS dismiss] dismissView reconnection begin 1");
        self.completionHandler(MEETING_STATUS_DISCONNECTED, status, [self generateErrorCallResultParam], self.meetingVC);
    }else{
        if (status != MEETING_STATUS_ABORTED && status != MEETING_STATUS_MEETINGNOTEXIST && status != MEETING_STATUS_SUCCESS) {
            InfoLog("[iOS dismiss] dismissView end");
            [self frtcCloseMeetingView];
        }
        InfoLog("[iOS dismiss] dismissView reconnection begin 2 ");
        self.completionHandler(MEETING_STATUS_DISCONNECTED, status, [self generateErrorCallResultParam], self.meetingVC);
    }
}

- (void)callStateTransition:(CallMeetingStatus)callMeetingStatus {
    for (FrtcMeetingStatusMachineTransition* transition in self.meetingStatusMachines) {
        if(transition.currentStatus == self.meetingStatus && transition.newMeetingStatus == static_cast<FRTCMeetingStatus>(callMeetingStatus)) {
            self.meetingStatus = transition.newMeetingStatus;
            transition.action();
            break;
        }
    }
}

- (void)frtcMakeCall:(FRTCSDKCallParam)callParam 
          controller:(UIViewController * _Nonnull )controller
      callCompletion:(FRTCSDKCallCompletionHandler)callCompletionHandler
     requestPassword:(void(^)())requestMeetingPassword
      contentRequest:(void(^)(void))contentRequest {
    
    [ObjectInterface sharedObjectInterface].callDelegate = self.callDelegate;

    if(callParam.password == nil) {
        callParam.password = @"";
    }
    
    if (!self.isReconnect) {
        self.password = nil;
    }
    
    NSString *serverAddress = [[[SDKUserDefault sharedSDKUserDefault] sdkObjectForKey:SKD_SERVER_ADDRESS] lowercaseString];
    if(serverAddress == nil || [serverAddress isEqualToString:@""]) {
        FRTCMeetingStatusReason result = MEETING_STATUS_SERVERERROR;
        self.completionHandler(MEETING_STATUS_DISCONNECTED, result, [self generateErrorCallResultParam], nil);
        return;
    }
    
    BOOL login =  [[SDKUserDefault sharedSDKUserDefault] sdkBoolObjectForKey:SKD_LOGIN_VALUE];
    
    self.completionHandler      = callCompletionHandler;
    
    if(callParam.callUrl != nil) {
        
        NSString *cipherString;
        NSDictionary *jsonDict;
        
        NSString *plainText = callParam.callUrl;
        NSData *afterDecodeData = [GTMBase64 decodeString:plainText];
        cipherString  =[[NSString alloc] initWithData:afterDecodeData encoding:NSUTF8StringEncoding];
        
        if (kIsEmpty(cipherString)) {
            NSData *afterDesData = [afterDecodeData AES256DecryptWithKey:key];
            cipherString  =[[NSString alloc] initWithData:afterDesData encoding:NSUTF8StringEncoding];
            if(kIsEmpty(cipherString)) {
                FRTCMeetingStatusReason result = MEETING_STATUS_MEETINGNOTEXIST;
                self.completionHandler(MEETING_STATUS_DISCONNECTED, result, [self generateErrorCallResultParam], nil);
                return;
            }
            jsonDict = [NSJSONSerialization JSONObjectWithData:afterDesData options:NSJSONReadingMutableLeaves error:nil];
        }else{
            jsonDict = [NSJSONSerialization JSONObjectWithData:afterDecodeData options:NSJSONReadingMutableLeaves error:nil];
            NSString *tempMeetingPasswd = [jsonDict[@"meeting_passwd"] lowercaseString];
            if (!kIsEmpty(tempMeetingPasswd)) {
                callParam.password = tempMeetingPasswd;
            }
        }
        
        callParam.conferenceNumber = jsonDict[@"meeting_number"];
        NSString *tempServerAddress = jsonDict[@"server_address"];
        
        if(login) {
            if([tempServerAddress isEqualToString:serverAddress]) {
            } else {
                login = NO;
                if (kStringIsEmpty(callParam.clientName)) {
                    callParam.clientName = [UIDevice currentDevice].name;
                }
            }
        }
        
        if(![tempServerAddress isEqualToString:serverAddress]) {
            serverAddress = tempServerAddress;
        } else {
        }
        
    }

    self.parentViewController   = controller;
    self.conferenceAlias        = callParam.conferenceNumber;
    self.clientName             = callParam.clientName;
    self.audioCall              = callParam.audioCall;
    self.floatWindow            = callParam.floatWindow;
    self.sharing                = callParam.sharing;
    if (!self.isReconnect) {
        self.muteCamera             = callParam.muteCamera;
        self.muteMicrophone         = callParam.muteMicrophone;
    }
    
    //self.completionHandler      = callCompletionHandler;
    self.passwordBlock          = requestMeetingPassword;
    self.contentRequestCallBack    = contentRequest;
    
    if(self.audioCall) {
        callParam.callRate = 64;
    } else {
        callParam.callRate = 0;
    }
    
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[ObjectInterface sharedObjectInterface] joinMeetingWithServerAddress:serverAddress conferenceAlias:callParam.conferenceNumber clientName:callParam.clientName userToken:callParam.userToken callRate:callParam.callRate meetingPassword:callParam.password isLogin:login
         meetingStatusCallBack:^(CallMeetingStatus callState, int reason) {
            weakSelf.reason = reason;
            [weakSelf callStateTransition:callState];
        } meetingParamsCallBack:^(NSString *conferenceName, NSString *meetingID, NSString *displayName, NSString *ownerID, NSString *ownerName, NSString *meetingUrl,  NSString * groupMeetingUrl, const long long scheduleStartTime,
                          const long long scheduleEndTime) {
            weakSelf.conferenceName = conferenceName;
            weakSelf.ownerID        = ownerID;
            weakSelf.ownerName      = ownerName;
            weakSelf.meetingUrl     = meetingUrl;
            weakSelf.scheduleStartTime = scheduleStartTime;
            weakSelf.scheduleEndTime   = scheduleEndTime;
            if(login) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakSelf.waitCallTimer != nil) {
                        [weakSelf.waitCallTimer invalidate];
                        weakSelf.waitCallTimer = nil;
                    }
                });
            }
        } requestPasswordCallBack:^{
            if(weakSelf.isReconnect && !kIsEmpty(weakSelf.password)) {
                [[ObjectInterface sharedObjectInterface] verifyPasscodeObject:weakSelf.password];
                return;
            }
            weakSelf.passwordBlock();
        } remoteLayoutChangeCallBack:^(SDKLayoutInfo buffer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self presentedViewController] remoteLayoutChanged:buffer];
            });
        } waterPrintCallBack:^(NSString *waterPrint, NSString *recordingStatus
                           ,NSString *liveStatus,
                           NSString *liveMeetingUrl,
                           NSString *liveMeetingPwd) {
            weakSelf.waterMarkString        = waterPrint;
            weakSelf.meetingRecordingStatus = recordingStatus;
            weakSelf.meetingLiveStatus      = liveStatus;
            weakSelf.meetingLiveMeetingUrl  = liveMeetingUrl;
            weakSelf.meetingLiveMeetingPwd  = liveMeetingPwd;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                InfoLog("[iOS Live] frtc call page");
                [[self presentedViewController] setRecordingStatus:recordingStatus liveStatus:liveStatus liveMeetingUrl:liveMeetingUrl liveMeetingPwd:liveMeetingPwd];
            });
            
        } remoteVideoReceivedCallBack:^(NSString *mediaID) {
            dispatch_async(dispatch_get_main_queue(), ^{
                InfoLog("[iOS mediaID] %s",[mediaID UTF8String]);
                [[self presentedViewController] remoteVideoReceived:mediaID];
            });
            
        } contentStreamRequestdCallBack:^(NSString *mediaID, int width, int height, int framerate) {
            [[ContentCaptureAdaper SingletonInstance] setMediaID:mediaID];
            weakSelf.contentRequestCallBack();
        }
    ];
        
        if(login) {
            self.waitCallTimer = [NSTimer plua_scheduledTimerWithTimeInterval:10.0 block:^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.completionHandler(MEETING_STATUS_DISCONNECTED, MEETING_STATUS_SERVERERROR, [self generateSuccessCallResultParam], nil);
            } repeats:NO];
        }
    });
}

- (NSString *)frtcGetCurrentVersion {
    NSString *version = [[ObjectInterface sharedObjectInterface] getVersion];
    return version;
}

- (void)frtcHangupCall {
    self.muteRemotePeopleVideo = NO;
    [[ObjectInterface sharedObjectInterface] endMeetingWithCallIndex:0];
    [[CaptureCameraStream SingletonInstance] resetDefaultVideoDevicePostion];
    [[CaptureCameraStream SingletonInstance] stopVideoCameraCapture];
}

- (BOOL)frtcGetCurrentVideoMuteStatus {
    return self.muteCamera;
}

- (BOOL)frtcGetCurrentAudioMuteStatus {
    return self.muteMicrophone;
}

- (void)frtcMuteLocalCamera:(BOOL)mute {
    bool muted = mute ? true : false;
    self.muteCamera = muted;
    [[ObjectInterface sharedObjectInterface] muteLocalVideoObject:muted];
    UIViewController *viewController = [self presentedViewController];
    if ([viewController isKindOfClass:[FrtcMeetingViewController class]]) {
        [(FrtcMeetingViewController *)viewController muteVideo:mute];
    }
}

- (void)frtcMuteLocalMicPhone:(BOOL)mute {
    bool muted = mute ? true : false;
    self.muteMicrophone = muted;
    [[ObjectInterface sharedObjectInterface] muteLocalAudioObject:muted];
    UIViewController *viewController = [self presentedViewController];
    if (viewController && [viewController isKindOfClass:[FrtcMeetingViewController class]]) {
        [(FrtcMeetingViewController *)viewController muteMicroPhone:mute];
    }
}

- (void)frtcMuteRemotePeopleVideo:(BOOL)mute {
    self.muteRemotePeopleVideo = mute;
    [[ObjectInterface sharedObjectInterface] muteRemoteVideoObject:mute];
    UIViewController *viewController = [self presentedViewController];
    if (viewController && [viewController isKindOfClass:[FrtcMeetingViewController class]]) {
        [(FrtcMeetingViewController *)viewController muteAllRemotePeopleVideo:mute];
    }
}

- (void)frtcHiddenLocalPreView:(BOOL)hidden {
    UIViewController *viewController = [self presentedViewController];
    if ([viewController isKindOfClass:[FrtcMeetingViewController class]]) {
        [(FrtcMeetingViewController *)viewController hidePreview:hidden];
    }
}

- (void)frtcShareContent:(BOOL)isShareContent {
    if(isShareContent) {
        [[ObjectInterface sharedObjectInterface] startSendContentObject];
        [[ObjectInterface sharedObjectInterface] setPeopleOnlyFlagObject:false];
    } else {
        [[ObjectInterface sharedObjectInterface] stopSendContentObject];
        [[ObjectInterface sharedObjectInterface] setPeopleOnlyFlagObject:true];
    }
}

- (void)frtcSwitchCameraPosition {
    [[self presentedViewController] switchVideoFrontOrRear];
}

- (void)frtcChangeSpeakerStatus:(BOOL)isSpeaker {
    [[self presentedViewController] setAudioSessionPortOverride:isSpeaker];
}

- (NSString *)frtcGetCallStaticsInfomation {
    return [[ObjectInterface sharedObjectInterface] getMediaStatisticsObject];
}

- (void)frtcSendCallPasscode:(NSString *)passcode {
    self.password = passcode;
    [[ObjectInterface sharedObjectInterface] verifyPasscodeObject:passcode];
}

- (void)frtcIntelligentDenoise:(BOOL)isDenoise {
    [[ObjectInterface sharedObjectInterface] setIntelligentNoiseReductionObject:isDenoise];
}

- (FRTCMeetingStatusReason)meetingStatusReason:(int)reason {
    FRTCMeetingStatusReason result;
    if (reason == 0) {
        result = MEETING_STATUS_SUCCESS;
    } else if(reason == 2) {
        result = MEETING_STATUS_ABORTED;
    } else if (reason == 3) {
        result = MEETING_STATUS_END_ABNORMAL;
    } else if (reason == 4) {
        result =  MEETING_STATUS_EXPIRED;
    } else if (reason == 5) {
        result = MEETING_STATUS_PEOPLE_FULL;
    } else if (reason == 6) {
        result =  MEETING_STATUS_INTERRUPT;
    } else if (reason == 7) {
        result = MEETING_STATUS_LOCKED;
    } else if (reason == 8) {
        result = MEETING_STATUS_MEETINGNOTEXIST;
    } else if (reason == 9) {
        result =  MEETING_STATUS_NOT_STARTED;
    } else if (reason == 10) {
        result =  MEETING_STATUS_STOP;
    } else if (reason == 11) {
        result = MEETING_STATUS_AUTHFAILED;
    } else if (reason == 14) {
        result =  MEETING_STATUS_PASSWORD_TOO_MANY_RETRIES;
    } else if (reason == 15) {
        result =  MEETING_STATUS_GUEST_UNALLOWED;
    } else if (reason == 17) {
        result = MEETING_STATUS_LICENSE_MAX_LIMIT_REACHED;
    } else if (reason == 18) {
        result = MEETING_STATUS_NO_LICENSE;
    } else if (reason == 19) {
        result =  MEETING_STATUS_REMOVE;
    } else if (reason == 20) {
        result = MEETING_STATUS_SERVERERROR;
    } else if (reason == 21) {
        result = MEETING_STATUS_REJECTED;
    } else {
        result = MEETING_STATUS_FAILED;
    }
    return result;
}


- (NSString *)frtcGetClientUUID {
    return [[FrtcUUID sharedUUID] getAplicationUUID];
}

- (NSInteger)frtcStartUploadLogs:(NSString *)metaData
                        fileName:(NSString *)fileName
                       fileCount:(int)fileCount {
    return [[ObjectInterface sharedObjectInterface] startUploadLogs:metaData fileName:fileName fileCount:fileCount];
}

- (NSString *)frtcGetUploadStatus:(int)tractionId fileType:(int)fileType; {
    return [[ObjectInterface sharedObjectInterface] getUploadStatus:tractionId fileType:fileType];
}

- (void)frtcCancelUploadLogs:(int)tractionId {
    [[ObjectInterface sharedObjectInterface] cancelUploadLogs:tractionId];
}

- (BOOL)frtcGetCurrentRemotePeopleVideoMuteStatus {
    return self.muteRemotePeopleVideo;
}

- (FrtcMeetingViewController *)presentedViewController {
    return self.meetingVC;
}

#pragma mark --Internal Function--
- (FRTCMeetingStatusSuccessParam)generateErrorCallResultParam {
    FRTCMeetingStatusSuccessParam callReaultParam;
    
    callReaultParam.conferenceName    = @"error";
    callReaultParam.conferenceAlias   = @"error";
    callReaultParam.ownerID           = @"error";
    callReaultParam.ownerName         = @"error";
    callReaultParam.meetingUrl        = @"error";
    callReaultParam.groupMeetingUrl   = @"error";
    callReaultParam.scheduleEndTime   = 0;
    callReaultParam.scheduleStartTime = 0;
    
    return callReaultParam;
}

- (FRTCMeetingStatusSuccessParam)generateSuccessCallResultParam {
    FRTCMeetingStatusSuccessParam callReaultParam;
 
    callReaultParam.conferenceName    = self.conferenceName;
    callReaultParam.conferenceAlias   = self.conferenceAlias;
    callReaultParam.ownerID           = self.ownerID;
    callReaultParam.ownerName         = self.ownerName;
    callReaultParam.meetingUrl        = self.meetingUrl;
    callReaultParam.groupMeetingUrl   = self.groupMeetingUrl;
    callReaultParam.scheduleEndTime   = self.scheduleEndTime;
    callReaultParam.scheduleStartTime = self.scheduleStartTime;
    
    return callReaultParam;
}

#pragma mark -- Floating Window

- (void)frtcCloseMeetingView {
    if (self.floatingWindow) {
        [self.floatingWindow destroy];
        self.floatingWindow = nil;
        [self.meetingVC.view removeFromSuperview];
        self.meetingVC = nil;
    }
}

- (void)frtcFloatingMeetingWindow:(BOOL)isSharing {
    
    [[self presentedViewController] floatingWindow:YES];
    
    if ([self presentedViewController].isPortrait) {
        [self changeFloatMeetingWindowWith:isSharing];
    }else{
        [[self presentedViewController] rotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.68 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeFloatMeetingWindowWith:isSharing];
        });
    }
}

- (void)changeFloatMeetingWindowWith:(BOOL)isSharing {
    
    self.floatWindow = YES;
    self.tempMuteCamera = self.muteCamera;
    if (!self.isTempMuteCamera) {
        [self frtcMuteLocalCamera:YES];
    }
    self.tempMuteRemotePeopleVideo = self.muteRemotePeopleVideo;
    if (!self.tempMuteRemotePeopleVideo) {
        [self frtcMuteRemotePeopleVideo:YES];
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGRect windowRect = self.floatingWindow.frame;
        windowRect.origin.x = UIScreen.mainScreen.bounds.size.width - 110;
        windowRect.origin.y = KNavBarHeight + 6;
        windowRect.size = CGSizeMake(104, 50);
        self.floatingWindow.frame = windowRect;
        self.floatingWindow.layer.cornerRadius  = 25;
        self.floatingWindow.layer.masksToBounds = YES;
        
        self.meetingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.meetingButton.backgroundColor = UIColorHex(0xf8f8f8);
        UIImage *rightImage = [UIImage imageBundlePath:@"frtc_floating_right"];
        [self.meetingButton setImage:rightImage forState:UIControlStateNormal];
        [self.meetingButton setTitle:isSharing ? NSLocalizedString(@"meeting_share_shareing", nil) : NSLocalizedString(@"meeting_share_inMeeting", nil) forState:UIControlStateNormal];
        [self.meetingButton setTitleColor:kMainColor forState:UIControlStateNormal];
        self.meetingButton.frame = self.floatingWindow.bounds;
        [self.meetingButton addTarget:self action:@selector(clickMeetingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.meetingButton setImageLayout:UIButtonLayoutImageRight space:8];
        //self.meetingButton.isSizeToFit = true;
        
        [self.floatingWindow.rootViewController.view insertSubview:self.meetingButton atIndex:100];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delaysTouchesBegan = YES;
        [self.meetingButton addGestureRecognizer:pan];
        
    } completion:^(BOOL finished) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [UIApplication sharedApplication].statusBarHidden = NO;
#pragma clang diagnostic pop
    }];
}

- (void)frtcChangeFloatButtonTitle:(NSString *)title {
    if (!kStringIsEmpty(title) && self.meetingButton) {
        [self.meetingButton setTitle:title forState:UIControlStateNormal];
    }
}

- (void)frtcChangeFloatWindowFrame {
    if (!ISIPAD) { return; }
    if (self.meetingButton) {
        self.floatingWindow.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                CGRect windowRect = self.floatingWindow.frame;
                windowRect.origin.x = KScreenWidth - 110;
                windowRect.origin.y = KNavBarHeight + 6;
                self.floatingWindow.frame = windowRect;
            } completion:^(BOOL finished) {
                self.floatingWindow.hidden = NO;
            }];
        });
    }
}

- (void)clickMeetingButtonAction:(UIButton *)button {
    self.floatWindow = NO;
    if (!self.tempMuteCamera) {
        [self frtcMuteLocalCamera:NO];
    }
    if (!self.tempMuteRemotePeopleVideo) {
        [self frtcMuteRemotePeopleVideo:NO];
    }
    [[self presentedViewController] floatingWindow:NO];
    [f_keyWindow() endEditing:YES];
    [self.meetingButton removeFromSuperview];
    self.meetingButton = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [UIApplication sharedApplication].statusBarHidden = YES;
#pragma clang diagnostic pop
    
    self.floatingWindow.alpha = 1;
    self.floatingWindow.layer.cornerRadius  = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingWindow.frame = [UIScreen mainScreen].bounds;
    }];
}

#pragma mark - event response
- (void)handlePanGesture:(UIPanGestureRecognizer*)p
{
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        //self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        self.floatingWindow.center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        //self.alpha = .7;
        CGPoint newCenter = [self checkNewCenterWithPoint:panPoint
                                                     size:self.meetingButton.frame.size];
        
        [UIView animateWithDuration:.25 animations:^{
            self.floatingWindow.center = newCenter;
        }];
    }else{
        ISMLog(@"pan state : %zd", p.state);
    }
}

- (CGPoint)checkNewCenterWithPoint:(CGPoint)point size:(CGSize)size {
    CGFloat ballWidth = size.width;
    CGFloat ballHeight = size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat left = fabs(point.x);
    CGFloat right = fabs(screenWidth - left);
    
    CGPoint newCenter = CGPointZero;
    CGFloat targetY = 0;
    
    //Correcting Y
    if (point.y < KNavBarHeight + ballHeight / 2.0) {
        targetY = KNavBarHeight + ballHeight / 2.0;
    }else if (point.y > (screenHeight - ballHeight / 2.0 - KTabbarHeight)) {
        targetY = screenHeight - ballHeight / 2.0 - KTabbarHeight;
    }else{
        targetY = point.y;
    }
    
    CGFloat centerXSpace = (0.5 - kHiddenProportion) * ballWidth + 25;
    
    if (left <= right) {
        newCenter = CGPointMake(centerXSpace, targetY);
    }else {
        newCenter = CGPointMake(screenWidth - centerXSpace, targetY);
    }
    
    return newCenter;
}

#pragma mark - iPad
- (void)onDidChangeOrientation {
    if (ISIPAD && self.meetingButton) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect windowRect = self.floatingWindow.frame;
            windowRect.origin.x = UIScreen.mainScreen.bounds.size.width - 110;
            windowRect.origin.y = KNavBarHeight + 6;
            self.floatingWindow.frame = windowRect;
        }];
    }
}

UIWindow *f_keyWindow(void) {
    static __weak UIWindow *cachedKeyWindow = nil;
    
    UIWindow *originalKeyWindow = nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        originalKeyWindow = window;
                        break;
                    }
                }
            }
        }
    } else
#endif
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
        originalKeyWindow = [UIApplication sharedApplication].keyWindow;
#endif
    }
    
    if (originalKeyWindow)
    {
        cachedKeyWindow = originalKeyWindow;
    }
    
    return cachedKeyWindow;
}

- (void)f_InfoLog:(NSString *)log {
    InfoLog("[iOS_Client] %s",[log UTF8String]);
}

@end





