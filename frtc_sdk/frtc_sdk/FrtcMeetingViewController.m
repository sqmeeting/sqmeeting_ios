#import "FrtcMeetingViewController.h"
#import "CaptureCameraStream.h"
#import "NSTimer+Enhancement.h"
#import "ObjectInterface.h"
#import "MeetingUserInformation.h"
#import "MeetingLayoutContext.h"
#import "FrtcAudioClient.h"
#import "Masonry.h"
#import "NSNotificationCenter+NotificationCenterAdditions.h"
#import <AVFoundation/AVFoundation.h>
#import "ContentCaptureAdaper.h"
#import "SendContentBackGroundView.h"
#import "FrtcUIMacro.h"
#import "FrtcAVAuthManager.h"
#import "FrtcCall.h"
#import "FrtcMeetingView.h"
#import "UIViewController+Orientations.h"
#include "log.h"

@interface FrtcMeetingViewController ()<CaptureCameraStreamDelegate, ObjectInterfaceDelegate, MeetingLayoutContextDelegate,UIGestureRecognizerDelegate,  FrtcAudioClientDelegate, ContentCaptureOutputBufferDelegate, UIScrollViewDelegate >
{
    int currentVideoOrientation;
    NSString *tempUUID;
    UIInterfaceOrientationMask currentVCInterfaceOrientationMask;
}

@property (nonatomic, strong) FrtcMeetingView *meetingView;
@property (nonatomic, strong) NSTimer                   *remoteTimer;

@property (nonatomic, copy)   NSString                   *pinUUID;
@property (nonatomic, copy)   NSString                   *activeSpeakerMediaID;
@property (nonatomic, copy)   NSString                   *tempContentUUID;
@property (nonatomic, strong) NSMutableArray<NSString *> *rosterListArray;
@property (nonatomic, strong) NSMutableArray<UserBasicInformation *> *remoteLayouts;

@property (nonatomic, assign, getter = isLocalViewHidden)   BOOL localViewHidden;
@property (nonatomic, assign, getter = isEnableWaterPrint)  BOOL enableWaterPrint;
@property (nonatomic, assign, getter = isSendingContent)    BOOL sendingContent;
@property (nonatomic, assign, getter = isContent)           BOOL content;
@property (nonatomic, assign, getter = isInterruptionBegan) BOOL interruptionBegan;

@end


@implementation FrtcMeetingViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(ISIPAD) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return currentVCInterfaceOrientationMask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorHex(0x000000);
    currentVCInterfaceOrientationMask = UIInterfaceOrientationMaskAllButUpsideDown;
    if (ISIPAD) {
        self.isPortrait = NO;
        currentVideoOrientation = VideoViewRotation_0;
    }else{
        self.isPortrait = YES;
        currentVideoOrientation = VideoViewRotation_90;
    }
    [self viewDidChangeOrientation];
    [self loadSubViewLayout];
    [self addProtocal];
}

- (void)loadSubViewLayout {
    
    [self.view addSubview:self.meetingView];
    [self.meetingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)addProtocal {
    
    if(!self.meetingModel.isAudioCall) {
        [MeetingLayoutContext SingletonInstance].delegate = self;
        [CaptureCameraStream SingletonInstance].delegate     = self;
        [CaptureCameraStream SingletonInstance].mediaID     = kLocalVideoMediaID;
        [FrtcAVAuthManager getAVAuthorization:AVMediaTypeVideo
                         withMeidaDescription:NSLocalizedString(@"CameraUsageDescription", nil)
                                     rootView:self];
        
        if(!self.meetingModel.isMuteCamera) {
            [[CaptureCameraStream SingletonInstance] configVideoSession];
        }
    }
    
    if(!self.meetingModel.audioCall) {
        [self muteVideo:self.meetingModel.isMuteCamera];
        [[ObjectInterface sharedObjectInterface] muteLocalVideoObject:self.meetingModel.isMuteCamera];
    }
    
    [FrtcAudioClient sharedAudioUnitCapture].delegate = self;
    [ObjectInterface sharedObjectInterface].delegate = self;
    [FrtcAVAuthManager getAVAuthorization:AVMediaTypeAudio
                     withMeidaDescription:NSLocalizedString(@"MicrophoneUsageDescription", nil)
                                 rootView:self];
    [[ContentCaptureAdaper SingletonInstance] setDelegate:self];
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [UIApplication sharedApplication].statusBarHidden = YES;
#pragma clang diagnostic pop
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [UIApplication sharedApplication].statusBarHidden = NO;
#pragma clang diagnostic pop
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [kFrtcCallShared f_InfoLog:@"[iOS Live] frtc meetinfg view page"];
        NSString *started_not = @"NOT_STARTED";
        if ([self.meetingModel.meetingRecordingStatus isEqualToString:started_not] &&
            [self.meetingModel.meetingLiveStatus isEqualToString:started_not]) { } else {
            [self setRecordingStatus:self.meetingModel.meetingRecordingStatus
                          liveStatus:self.meetingModel.meetingLiveStatus
                      liveMeetingUrl:self.meetingModel.meetingLiveMeetingUrl
                      liveMeetingPwd:self.meetingModel.meetingLiveMeetingPwd];
            self.meetingModel.meetingRecordingStatus = started_not;
            self.meetingModel.meetingLiveStatus = started_not;
        }
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation;
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            [kFrtcCallShared f_InfoLog:@"[Orientation] viewDidAppear"];
            self->currentVideoOrientation = VideoViewRotation_0;
        }
    });
}

- (void)dealloc {
    //[self cancelTimer];
    ISMLog(@"%s",__func__);
    [self dropCall];
}

#pragma mark -  layout
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (ISIPAD) { return; }
    [self viewWillBeginTransitionWithSize:size];
    @WeakObj(self)
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        @StrongObj(self)
        [self viewWillChangeCurrentDeviceRoration];
        [self viewDidEndTransitionWithSize:size];
    } completion:nil];
}

- (void)viewWillChangeCurrentDeviceRoration {
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [kFrtcCallShared f_InfoLog:@"[Orientation] UIInterfaceOrientationPortrait"];
            currentVideoOrientation = currentVideoOrientation == VideoViewRotation_180 ?  VideoViewRotation_270 : VideoViewRotation_90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            [kFrtcCallShared f_InfoLog:@"[Orientation] UIInterfaceOrientationLandscapeRight"];
            currentVideoOrientation = VideoViewRotation_0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [kFrtcCallShared f_InfoLog:@"[Orientation] UIInterfaceOrientationLandscapeLeft"];
            currentVideoOrientation = VideoViewRotation_180;
            break;
        default:
            break;
    }
}

- (void)viewWillBeginTransitionWithSize:(CGSize)size {
    if (size.width > size.height) {
        self.isPortrait = NO;
        [self viewDidChangeOrientation];
        [self.meetingView getLandscapeFrame];
    } else {
        self.isPortrait = YES;
        [self viewDidChangeOrientation];
        [self.meetingView getPortraitFrame];
    }
    [self.meetingView updateVideoLayout];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
        [self.meetingView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self updateVideoArrangeLayout];
    }];
}

- (void)viewDidEndTransitionWithSize:(CGSize)size {
    [self.meetingView.scrollView setZoomScale:self.meetingView.scrollView.minimumZoomScale];
}

#pragma mark -- Notification

- (void)registerNotification {
    [kNotificationCenter addObserver:self selector:@selector(onParticipantsList:) name:FMeetingParticipantsListKeyNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(onRemoveContentBackGroundView:) name:@"com.fmeeting.removeContentBackView" object:nil];
    [kNotificationCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [kNotificationCenter addObserver:self selector:@selector(audioSessionRouteChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(audioSessionInterruptionObserver:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)applicationDidEnterBackground {
    [FrtcAVAuthManager setAudioSessionCategoryOptions];
}

- (void)applicationWillEnterForeground {
    if (self.isInterruptionBegan) {
        InfoLog("[iOS] audioSessionInterruptionObserver applicationWillEnterForeground");
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        self.interruptionBegan = NO;
        [[FrtcAudioClient sharedAudioUnitCapture] enableAudioUnitCoreGraph];
        [self setAudioSessionPortOverride:[FrtcAVAuthManager isHeadsetPluggedIn]];
    }
}

- (void)onParticipantsList:(NSNotification *)ntf {
    NSDictionary *userInfo = ntf.userInfo;
    _rosterListArray = [userInfo valueForKey:FMeetingParticipantsListKey];
    [self.meetingView updateParticipantsListState:_rosterListArray];
}

- (void)onRemoveContentBackGroundView:(NSNotification *)ntf {
    for(UIView *contentBackView in [self.view subviews])
    {
        if ([contentBackView isKindOfClass:[SendContentBackGroundView class]]) {
            self.sendingContent = NO;
            [contentBackView removeFromSuperview];
        }
    }
}

- (void)audioSessionInterruptionObserver:(NSNotification *)notification {
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        InfoLog("[iOS] audioSessionInterruptionObserver Interruption Began");
        self.interruptionBegan = YES;
        [[FrtcAudioClient sharedAudioUnitCapture] disableAudioUnitCoreGraph];
    }
    else if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        InfoLog("[iOS] audioSessionInterruptionObserver Interruption Ended");
        self.interruptionBegan = NO;
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[FrtcAudioClient sharedAudioUnitCapture] enableAudioUnitCoreGraph];
        [self setAudioSessionPortOverride:[FrtcAVAuthManager isHeadsetPluggedIn]];
    }
}

- (void)audioSessionRouteChangeObserver:(NSNotification*)notification {
    NSDictionary *routeChangeUserInfo = notification.userInfo;
    NSInteger audioSessionRouteChangeValue = [[routeChangeUserInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (audioSessionRouteChangeValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            [self setAudioSessionPortOverride:YES];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self setAudioSessionPortOverride:NO];
            break;
    }
}

- (void)viewDidChangeOrientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callDelegate && [self.callDelegate respondsToSelector:@selector(onDidChangeOrientation:)]) {
            [self.callDelegate onDidChangeOrientation:self.isPortrait];
        }
        
        if (self.onDidChangeOrientation && ISIPAD) {
            self.onDidChangeOrientation();
        }
    });
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ) {
        return NO;
    }
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    if ([touch.view isDescendantOfView:self.meetingView.sendContentBackGroundView]) {
        return YES;
    }
    
    return YES;
}

- (BOOL)isPinedByOperator:(NSString *)uuid {
    if([uuid isEqualToString:self.pinUUID]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Interface for Client user

- (void)muteMicroPhone:(BOOL)mute {
    self.meetingModel.muteMicrophone = mute;
    [self.meetingView.localVideoView.siteNameView renewSiteNameViewByUserMuteStatus:mute];
}

- (void)muteVideo:(BOOL)isMute; {
    self.meetingModel.muteCamera = isMute ? YES : NO;
    
    if(isMute) {
        [[CaptureCameraStream SingletonInstance] captureSessionStopRunning];
        [self.meetingView.localVideoView renderMuteImage:isMute];
        [self.meetingView.localVideoView stopRendering];
    } else {
        if (![CaptureCameraStream SingletonInstance].isStartingVideoCapture && currentVideoOrientation == VideoViewRotation_270) {
            [kFrtcCallShared f_InfoLog:@"[Orientation] muteVideo"];
            currentVideoOrientation = VideoViewRotation_90;
        }
        [[CaptureCameraStream SingletonInstance] captureSessionStartRunning];
        [self.meetingView.localVideoView startRendering];
        
        __weak __typeof(self)weakSelf = self;
        [NSTimer plua_scheduledTimerWithTimeInterval:0.25 block:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.meetingView.localVideoView renderMuteImage:isMute];
        } repeats:NO];
    }
}

- (void)hidePreview:(BOOL)isHide {
    self.meetingView.localVideoView.hidden = isHide;
    self.meetingView.localViewHidden = isHide;
}

- (void)switchVideoFrontOrRear {
    [[CaptureCameraStream SingletonInstance] selectVideoDeviceByPostion];
}

- (void)setAudioSessionPortOverride:(BOOL)isSpeaker {
    [FrtcAVAuthManager setAudioSessionPortOverride:isSpeaker];
}

- (void)updateVideoArrangeLayout {
    NSMutableArray *viewArray = [[MeetingLayoutContext SingletonInstance] participantsList];
    MeetingLayoutNumber mode = [[MeetingLayoutContext SingletonInstance] meetingNumber];
    [self updateRemoteUserNumber:mode Views:viewArray];
}

- (void)stopRender {
    [self.meetingView stopRender];
}

- (void)waterPrint:(NSString *)waterPrint {
    if (kStringIsEmpty(waterPrint)) { return; }
    NSData *jsonData = [waterPrint dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(!err) {
        ISMLog(@"%@", dic);
        self.enableWaterPrint = [(NSNumber *)dic[@"enable"] boolValue];
    }
}

- (void)remoteLayoutChanged:(SDKLayoutInfo)buffer {
    
    __weak __typeof(self)weakSelf = self;
    self.remoteLayouts = buffer.layout;
    
    bool isContent;
    if(!self.isSendingContent) {
        isContent = buffer.bContent ? YES : NO;
    } else {
        isContent = NO;
    }
    
    if(isContent) {
        if(self.meetingModel.audioCall) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.meetingView.pageControl.hidden = NO;
        });
        
        if(!self.content) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.content = YES;
                if(weakSelf.isEnableWaterPrint) {
                    [weakSelf.meetingView.contentVideoView configContentWaterMask:self.meetingModel.callName];
                }
                [self.meetingView updateBottomViewLayout:YES];
            });
        }
    } else {
        self.content = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.meetingView updateBottomViewLayout:NO];
        });
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    self.activeSpeakerMediaID = buffer.activeSpeakerUuId;
    self.pinUUID                   = buffer.pinUUID;
    
    __block NSMutableArray *svcLayoutInfo = [NSMutableArray arrayWithCapacity:PEOPLE_VIDEO_AND_CONTENT_NUMBER];
    
    for(int i = 0; i < self.remoteLayouts.count; i++) {
        UserBasicInformation *valueItem = self.remoteLayouts[i];
        
        MeetingUserInformation *meetingUserInfo = [[MeetingUserInformation alloc] init];//C_R_
        if([valueItem.mediaID containsString:@"VCR"]) {
            [self.meetingView.contentVideoView setRenderMediaID:valueItem.mediaID];
            NSString *contentStr = valueItem.userDisplayName;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *strUUid  = [valueItem.userUUID stringByReplacingOccurrencesOfString:@"VCR-" withString:@""];
                if (![weakSelf.tempContentUUID isEqualToString:strUUid]) {
                    [weakSelf.meetingView.scrollView setZoomScale:weakSelf.meetingView.scrollView.minimumZoomScale];
                }
                weakSelf.meetingView.contentVideoView.siteNameView.nameStr = contentStr;
                weakSelf.meetingView.contentVideoView.uuid = strUUid;
                [weakSelf.meetingView getCurrentContentAudioMuteState:weakSelf.rosterListArray];
                weakSelf.tempContentUUID = strUUid;
            });
            
        } else {
            meetingUserInfo.mediaID      = valueItem.mediaID;
            meetingUserInfo.resolution_height = (int)valueItem.resolutionHeight;
            meetingUserInfo.resolution_width  = (int)valueItem.resolutionWidth;
            meetingUserInfo.display_name      = valueItem.userDisplayName;
            meetingUserInfo.uuid           = valueItem.userUUID;
            meetingUserInfo.removed           = NO;
            meetingUserInfo.pin = [self isPinedByOperator:valueItem.userUUID];
            [svcLayoutInfo addObject:meetingUserInfo];
        }
    }
    
    [[MeetingLayoutContext SingletonInstance] updateMeetingUserList:svcLayoutInfo];
}

- (void)remoteVideoReceived:(NSString *)mediaID {
    [self.meetingView remoteVideoReceived:mediaID];
}

- (void)onVideoFrozen:(NSString *)mediaID videoFrozen:(BOOL)bFrozen {
    [self.meetingView onVideoFrozen:mediaID videoFrozen:bFrozen];
}

- (void)setRecordingStatus:(NSString *)recordingStatus
                liveStatus:(NSString *)liveStatus
            liveMeetingUrl:(NSString *)liveMeetingUrl
            liveMeetingPwd:(NSString *)liveMeetingPwd {
    NSDictionary *userInfo = @{@"recordingStatus":recordingStatus,@"liveStatus":liveStatus,@"liveMeetingUrl":liveMeetingUrl,@"liveMeetingPwd":liveMeetingPwd};
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callDelegate && [self.callDelegate respondsToSelector:@selector(onRecordingLiveStateChange:)]) {
            [self.callDelegate onRecordingLiveStateChange:userInfo];
        }
    });
}

- (void)muteAllRemotePeopleVideo:(BOOL)isMute {
    [self.meetingView muteAllRemotePeopleVideo:isMute rosterListArray:_rosterListArray];
}

- (void)floatingWindow:(BOOL)isFloat {
    if (isFloat) {
        currentVCInterfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    }else{
        currentVCInterfaceOrientationMask = UIInterfaceOrientationMaskAllButUpsideDown;
    }
    [self f_setNeedsUpdateOfSupportedInterfaceOrientations];
}

- (BOOL)rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self f_rotateToInterfaceOrientation:interfaceOrientation];
}

- (void)dropCall {
    [CaptureCameraStream SingletonInstance].startingVideoCapture = NO;
    [kNotificationCenter removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [kNotificationCenter removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [kNotificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [kNotificationCenter removeObserver:self name:@"com.fmeeting.removeContentBackView" object:nil];
    [kNotificationCenter removeObserver:self name:FMeetingParticipantsListKeyNotification object:nil];
}

#pragma mark - MeetingLayoutContextDelegate

- (void)updateRemoteUserNumber:(MeetingLayoutNumber)number Views:(NSArray*)userArray {
    
    [self.meetingView updateLocalVideoViewLayout:userArray content:self.content isPortrait:self.isPortrait];
    self.meetingView.localVideoView.siteNameView.nameStr = self.meetingModel.callName;
    [self.meetingView updateRemotePeopleVideoBottomViewSubViewsHidden:userArray];
    [self.meetingView updateRemotePeopleVideoViewState:userArray
                                                 model:number
                                       rosterListArray:_rosterListArray
                                  activeSpeakerMediaID:self.activeSpeakerMediaID];
    
    if (![self->tempUUID isEqualToString:self.pinUUID]) {
        __block NSMutableArray *userInfo = [NSMutableArray arrayWithCapacity:1];
        if (!kStringIsEmpty(self.pinUUID)) {
            [userInfo addObject:self.pinUUID];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.callDelegate && [self.callDelegate respondsToSelector:@selector(onPeopleVideoPinList:)]) {
                [self.callDelegate onPeopleVideoPinList:userInfo];
            }
        });
    }
    self->tempUUID = self.pinUUID;
}

#pragma mark - ContentCaptureOutputBufferDelegate
- (void)outputContentBuffer:(void * _Nonnull)buffer length:(int)length width:(int)width height:(int)height type:(RTC::VideoColorFormat)type mediaID:(NSString *)mediaID roration:(int )roration {
    if (ISIPAD) {
        [[ObjectInterface sharedObjectInterface] startSendContentStream:mediaID videoBuffer:buffer length:length width:width height:height videoSampleType:type rotation:roration];
    }else{
        roration = roration == VideoViewRotation_0 ? VideoViewRotation_270 : VideoViewRotation_0;
        [[ObjectInterface sharedObjectInterface] startSendContentStream:mediaID videoBuffer:buffer length:length width:width height:height videoSampleType:type rotation:roration];
    }
}

#pragma mark - ObjectInterfaceDelegate
- (void)onContentStreamRequested:(NSString *)mediaID width:(int)width height:(int)height framerate:(float)framerate {
    [[ContentCaptureAdaper SingletonInstance] setMediaID:mediaID];
    [[ContentCaptureAdaper SingletonInstance] setDelegate:self];
}

- (void)contentStateChanged:(BOOL)isSending {
    if (isSending && self.sendingContent) {
        return;
    }
    if (!isSending && !self.sendingContent) {
        return;
    }
    
    [self.meetingView addRemoveSendContentBackGroundView:isSending];
    
    self.sendingContent = isSending;
}

#pragma mark - FrtcAudioClientDelegate
- (void)sendAudioDataFrame:(unsigned char *)buffer length:(int)length sampleRate:(int)sampleRate {
    [[ObjectInterface sharedObjectInterface] sendAudioFrameObject:buffer length:length sampleRatge:sampleRate];
}

- (void)receiveAudioFrame:(void *)buffer length:(unsigned int)length sampleRate:(unsigned int)sampleRate {
    [[ObjectInterface sharedObjectInterface] receiveAudioFrameObject:buffer dataLength:length sampleRate:sampleRate];
}

#pragma mark - CaptureCameraStreamDelegate
- (void)outputVideoBuffer:(void *)buffer mirrorBuffer:(void*)buffer_mirror length:(int)length width:(int)width height:(int)height type:(RTC::VideoColorFormat)type mediaID:(NSString *)mediaID {
    int rotation = currentVideoOrientation == VideoViewRotation_180 ? VideoViewRotation_0 : currentVideoOrientation;
    [[ObjectInterface sharedObjectInterface] sendVideoFrameObject:mediaID videoBuffer:buffer length:length width:width height:height  rotation:rotation videoSampleType:type];
}

#pragma mark - lazy
- (FrtcMeetingView *)meetingView {
    if (!_meetingView) {
        _meetingView = [[FrtcMeetingView alloc]initWithFrame:CGRectZero];
    }
    return _meetingView;
}

@end

